# Lumi Product Analytics and Engagement Execution Plan

## Objective

Build a reliable measurement system that explains where users drop, what prevents activation, which product experiences create learning value, and which errors damage engagement.

The first product outcome this plan optimizes is:

> A new user completes their first lesson within 24 hours of creating an account.

The supporting funnel is:

`signup_completed -> onboarding_completed -> course_saved -> course_opened -> first_lesson_started -> first_lesson_completed`

This plan covers the Flutter app in `lumi_learn` and the Fastify/Firestore backend in `lumi-api`.

## Success criteria

The work is complete when the team can answer, from production data:

1. What percentage of new users complete each activation step?
2. How long does each step take at p50 and p90?
3. Where and why do users abandon onboarding, course creation, paywalls, and lessons?
4. What percentage of course generations and saves succeed?
5. Which errors affect the most users and correlate with lower activation or retention?
6. Which acquisition, onboarding, content, and paywall variants improve first-lesson completion?
7. Can every generation, save, purchase, and lesson attempt be traced across client and server logs?

Initial targets should be baselined after two weeks of trustworthy production data rather than invented before instrumentation exists.

## Guiding decisions

- Use Firebase Analytics for Flutter behavioral events and screen views.
- Use Firebase Crashlytics for fatal errors and selected non-fatal failures.
- Export Analytics and Crashlytics data to BigQuery for funnel and cohort analysis.
- Emit authoritative server events for course generation, saving, and lesson persistence.
- Use RevenueCat webhooks as the authoritative subscription lifecycle source.
- Keep Firestore product state separate from append-only analytics events.
- Do not send raw documents, filenames, email addresses, usernames, lesson answers, or voice transcripts to analytics.
- Use stable event names and properties. Do not encode IDs, screens, or error messages into event names.

## Phase 0: Correctness and data integrity

**Goal:** ensure tracked outcomes describe what actually happened.

### 0.1 Lesson completion correctness

- Only show the lesson victory screen after the server confirms progress was saved.
- If saving fails, retain the completed lesson locally, show a retry state, and retry with an idempotency key.
- Add a unique `lesson_attempt_id` created when a lesson starts.
- Make lesson completion and XP award idempotent on `(user_id, course_id, lesson_id, lesson_attempt_id)`.
- Move XP mutation into the same Firestore transaction as completion, or record a durable award ledger inside that transaction.
- Include `lessonId`, `lessonAttemptId`, `xpAwarded`, and `wasPreviouslyCompleted` in the server event.

**Acceptance criteria**

- Network failure cannot produce a false success screen.
- Replaying or retrying the same completion cannot award XP twice.
- A failed request can be retried safely.
- A completion event identifies the exact lesson and attempt.

### 0.2 Course lifecycle correctness

- Add a course lifecycle field: `queued`, `uploading`, `extracting`, `generating`, `saving`, `ready`, or `failed`.
- Add `generationId`, `generationStartedAt`, `readyAt`, `failedAt`, `failureStage`, and stable `failureCode` fields.
- Do not return course creation success until the saved-course record is confirmed.
- Stop swallowing auto-save failures.
- Make saved-course creation idempotent.
- Decide whether failed course shells should be deleted automatically or retained for retry; do not leave indefinite `Generating Course...` records.
- Generate podcasts asynchronously after the course is marked ready.

**Acceptance criteria**

- A successful API response always corresponds to a durable course and saved-course record.
- Failed generations are queryable by stage and error code.
- The user can open the course without waiting for podcast generation.
- Repeating a save request cannot increment `savedCount` more than once.

### 0.3 Onboarding persistence

- Persist onboarding username/profile choice or remove the duplicate prompt if Firebase already has a usable display name.
- Persist selected subject IDs on the user profile.
- Record the onboarding version and completion timestamp.
- Distinguish `onboarding_completed` from `onboarding_skipped`.
- Use selected subjects to populate the first home experience.

**Acceptance criteria**

- Onboarding choices survive an app restart.
- Home recommendations visibly reflect at least one selected subject.
- Completion status is not changed locally if the backend update fails without a queued retry.

### 0.4 Paywall correctness

- Show course-slot availability before the user begins uploading or entering content.
- Keep the final server-side entitlement/limit check authoritative.
- Add Restore Purchases to both subscription surfaces.
- Display store-provided product price/currency rather than treating hard-coded copy as authoritative.

## Phase 1: Analytics foundation

**Goal:** provide one safe API for behavioral events and one consistent context envelope.

### 1.1 Flutter analytics service

Add an `AnalyticsService` wrapper rather than calling Firebase directly from screens.

Responsibilities:

- Log typed events.
- Set and clear the authenticated user identifier.
- Set user properties such as plan, onboarding version, and role.
- Attach default context.
- Generate and propagate correlation IDs.
- Sanitize parameters and prevent prohibited content.
- Become a no-op when analytics collection is disabled.
- Support DebugView validation in development builds.

Default client context:

| Property | Purpose |
|---|---|
| `event_schema_version` | Allows safe event evolution |
| `session_id` | Groups user activity |
| `app_version` / `build_number` | Finds release regressions |
| `platform` / `os_version` | Device segmentation |
| `locale` / `timezone` | Localization and notification analysis |
| `screen_name` | Current product context |
| `subscription_tier` | Free versus premium behavior |
| `onboarding_version` | Funnel comparison |
| `experiment_ids` | Experiment attribution |

### 1.2 Navigation and session instrumentation

- Add an analytics navigator observer alongside the existing route observer.
- Explicitly instrument tab changes and overlay-style flows that do not create routes.
- Track app foreground/background transitions.
- Log `session_started`, `session_ended`, `screen_viewed`, and `navigation_clicked`.
- Use product screen names rather than Dart class names.

### 1.3 Crashlytics and non-fatal errors

- Initialize Crashlytics immediately after Firebase.
- Capture Flutter framework errors, uncaught async errors, and isolate errors.
- Record selected caught exceptions with stack traces.
- Attach safe keys: screen, feature, action, generation ID, course ID, lesson attempt ID, plan, and build.
- Replace high-value `print`-only and empty-catch paths with structured reporting.
- Never attach raw lesson answers, chat messages, transcripts, uploaded content, or personal profile values.

### 1.4 Server event emitter

Create one backend event-emission module with:

- Event schema validation.
- Server timestamp.
- Idempotent `event_id` support.
- `user_id`, `anonymous_id` when available, and correlation IDs.
- Environment and deployment version.
- Request ID and safe error classification.
- A single append-only destination suitable for BigQuery export.

Server-authoritative events include generation completion/failure, course save, lesson completion, and subscription lifecycle changes.

### 1.5 Request correlation

- Generate a request ID in the client for important mutations.
- Pass it as an HTTP header.
- Include it in Fastify logs, server events, and error responses.
- Use separate domain IDs where needed: `generation_id`, `paywall_view_id`, and `lesson_attempt_id`.

**Phase 1 acceptance criteria**

- A test session is visible from app open through navigation in DebugView.
- A forced fatal and a forced caught exception appear in Crashlytics with safe context.
- A course-generation request can be followed from client submission to server completion by correlation ID.
- Automated tests reject event payloads containing prohibited keys or oversized values.

## Phase 2: Activation funnel

**Goal:** measure the complete journey from signup to first lesson completion.

### Event contract

| Event | Authority | Required properties |
|---|---|---|
| `signup_started` | Client | `auth_method`, `entry_source` |
| `signup_completed` | Client/server | `auth_method`, `is_new_user` |
| `auth_failed` | Client | `auth_method`, `error_code`, `recoverable` |
| `onboarding_started` | Client | `onboarding_version` |
| `onboarding_step_viewed` | Client | `step_id`, `step_index` |
| `onboarding_step_completed` | Client | `step_id`, `duration_ms`, safe step-specific counts |
| `onboarding_back_clicked` | Client | `from_step`, `to_step` |
| `onboarding_abandoned` | Derived | `last_step`, `elapsed_ms` |
| `onboarding_completed` | Server | `duration_ms`, `subject_count`, `path` |
| `catalog_course_opened` | Client | `course_id`, `subject`, `source_surface` |
| `course_saved` | Server | `course_id`, `save_type`, `source_surface` |
| `course_opened` | Client | `course_id`, `course_type`, `source_surface` |
| `lesson_started` | Client | `course_id`, `lesson_id`, `lesson_attempt_id`, `lesson_ordinal` |
| `lesson_completed` | Server | `course_id`, `lesson_id`, `lesson_attempt_id`, `duration_ms`, `xp_awarded` |

`first_lesson_started` and `first_lesson_completed` should normally be derived from a user's earliest lesson events rather than emitted as separate competing facts.

### Funnel dashboard

Build a dashboard containing:

- Unique users at each activation step.
- Step-to-step conversion.
- Total signup-to-completion conversion.
- p50/p75/p90 duration between steps.
- Breakdown by auth method, onboarding version, platform, app version, and activation path.
- A seven-day trend with release annotations.

**Acceptance criteria**

- Every test account appears once in the activation funnel.
- Existing-user login is not misclassified as signup.
- Repeated lesson completion does not change first-lesson activation.
- Client and server timestamps are both available for clock-skew investigation.

## Phase 3: Course creation and save observability

**Goal:** identify creation friction, latency, and reliability problems.

### Client events

- `course_create_opened`
- `course_input_type_selected`
- `course_source_added`
- `course_source_rejected`
- `course_generation_submitted`
- `course_generation_cancelled`
- `course_generation_result_viewed`
- `course_opened`

### Server events

- `course_generation_started`
- `course_generation_stage_completed`
- `course_generation_completed`
- `course_generation_failed`
- `course_save_started`
- `course_saved`
- `course_save_failed`

### Required generation properties

- `generation_id`
- `course_id` once reserved
- `input_types`
- `file_count`
- coarse `total_bytes_bucket`
- `plain_text_length_bucket`
- `from_onboarding`
- `class_assignment_requested`
- `stage`
- `stage_duration_ms`
- `total_duration_ms`
- `chunks_generated`
- `flashcards_generated`
- `lessons_generated`
- `failure_code`
- `http_status`
- `retry_count`

### Timings to capture independently

1. Time spent in the creation form.
2. Client upload time.
3. Server upload/storage time.
4. Extraction and chunking time.
5. Embedding time.
6. AI content generation time.
7. Summary generation time.
8. Firestore finalization time.
9. Saved-course creation time.
10. API total time.
11. Time until the user first sees the ready state.
12. Time from ready state to course open and first lesson start.

### Creation dashboard

- Start -> submit -> success -> save -> open -> lesson start conversion.
- Success and failure rate by input type and app version.
- p50/p90/p99 duration by stage.
- Failure code and failure stage distribution.
- Orphaned/stuck course count by lifecycle status.
- Generated but never opened courses.
- Opened but never started courses.

## Phase 4: Lesson-quality and abandonment analytics

**Goal:** determine why users leave lessons and which interactions help them learn.

### Events

- `lesson_started`
- `question_viewed`
- `question_answered`
- `question_skipped`
- `lesson_paused`
- `lesson_resumed`
- `lesson_abandoned`
- `lesson_completed`
- `course_completed`

### Properties

- course, lesson, and attempt IDs
- lesson ordinal and total lesson count
- question ordinal and total question count
- question type
- correct/incorrect
- attempt number
- response time
- retry or repeat status
- score and earned XP
- entry source
- time since course save

For speaking and writing, store only classification, score, duration, retry count, and failure code in analytics. Keep raw content in its purpose-specific product storage only when required by the feature and privacy policy.

### Derived measures

- Lesson start-to-completion rate.
- Median lesson duration.
- Abandonment by question ordinal and type.
- Incorrect-attempt and skip rates.
- First lesson versus later lesson completion.
- Repeat lesson behavior.
- Course completion rate.
- D1/D7 return rate after first lesson.

## Phase 5: Paywall and subscription lifecycle

**Goal:** understand monetization without confusing client intent with store outcomes.

### Client events

| Event | Required properties |
|---|---|
| `paywall_viewed` | `paywall_view_id`, `trigger`, `paywall_version`, slot usage |
| `paywall_plan_selected` | `plan_id`, displayed price/currency |
| `purchase_started` | `plan_id`, `paywall_view_id` |
| `purchase_cancelled` | store error code, elapsed time |
| `purchase_failed` | normalized error code, recoverable |
| `purchase_completed_client` | product ID, transaction environment |
| `paywall_dismissed` | duration, selected plan, dismissal method |
| `restore_started` | entry surface |
| `restore_completed` | entitlement restored boolean |
| `restore_failed` | normalized error code |

### Server lifecycle events

Consume RevenueCat webhooks idempotently and store:

- `subscription_started`
- `subscription_renewed`
- `subscription_cancelled`
- `subscription_uncancelled`
- `subscription_billing_issue`
- `subscription_expired`
- `subscription_refunded`

Verify webhook authorization, deduplicate on RevenueCat event ID, preserve production versus sandbox, and update backend entitlement state.

### Paywall dashboard

- View -> plan select -> purchase start -> verified subscription conversion.
- Conversion by trigger and paywall version.
- Dismissal and cancellation rate.
- Store failure rate by product/app version.
- Monthly versus yearly selection and verified conversion.
- Renewal, billing issue, cancellation, and expiration cohorts.

## Phase 6: Error observability and support loop

**Goal:** connect technical failures to affected users and product outcomes.

### Error taxonomy

Use stable codes such as:

- `auth_token_missing`
- `auth_provider_cancelled`
- `network_unavailable`
- `request_timeout`
- `course_input_unsupported`
- `course_input_too_large`
- `course_extraction_failed`
- `course_generation_provider_failed`
- `course_save_failed`
- `course_load_failed`
- `lesson_progress_save_failed`
- `speech_permission_denied`
- `speech_recognition_failed`
- `purchase_offerings_unavailable`
- `purchase_network_failed`
- `purchase_entitlement_pending`
- `notification_permission_denied`

### Action failure event

Log `action_failed` with:

- feature
- action
- stable error code
- recoverable/fatal
- client/server origin
- HTTP status
- request and domain correlation IDs
- elapsed time
- retry count
- app/build/platform context

### Operational dashboard and alerts

- Crash-free users and sessions.
- Non-fatal failures per 1,000 sessions.
- Course-generation and lesson-save failure rate.
- Top failures by affected users, not raw occurrence count.
- Failure rate by release.
- Alert when a core mutation failure rate exceeds its baseline or when a new fatal issue appears.

## Phase 7: UX experiments

Run experiments only after event quality is verified.

### Experiment 1: Activation path

- Control: current mandatory first-course creation.
- Variant: immediately recommend a ready-made course from the user's selected subjects and launch a short first lesson.
- Primary metric: first lesson completed within 24 hours.
- Guardrails: onboarding completion, D1 retention, errors, and course creation within seven days.

### Experiment 2: Post-generation destination

- Control: generated-course overview/map.
- Variant: explicit `Start first lesson` CTA or direct first-lesson entry.
- Primary metric: generated -> first lesson started.

### Experiment 3: Home continuation

- Control: current course list.
- Variant: a prominent `Continue learning` card based on most recent incomplete lesson.
- Primary metric: home visit -> lesson start.

### Experiment 4: Early slot disclosure

- Control: slot/paywall check on generation submission.
- Variant: visible slot count and paywall disclosure on create entry.
- Primary metric: course creation starts that produce a saved course.
- Guardrail: paywall conversion and creation abandonment.

## Data model and governance

### Event identity

- `event_id`: unique and used for deduplication.
- `event_name`: stable snake_case name.
- `occurred_at`: client occurrence timestamp.
- `received_at`: server ingestion timestamp.
- `user_id`: Firebase UID after authentication.
- `anonymous_id`: pre-auth installation/session identity.
- `session_id`: app session.
- `request_id`: one network request.
- Domain IDs: generation, paywall view, course, lesson attempt, or experiment.

### Privacy rules

Prohibit these fields in behavioral analytics:

- email, username, full name, or notification token
- raw uploaded text, filenames, or file URLs
- raw tutor messages
- raw written answers or speech transcripts
- generated question and answer text
- unrestricted exception strings that may include user content

Use subject IDs, content-type categories, count/size buckets, scores, durations, and stable error codes instead.

### Retention

- Document retention separately for analytics, crashes, server logs, and feature content.
- Support account deletion across user-linked analytics systems where required.
- Keep development, sandbox, and production data distinguishable.
- Restrict raw event access; provide dashboards for routine product use.

## Testing strategy

### Automated tests

- Event schema validation tests.
- Analytics sanitizer tests.
- Idempotency tests for lesson completion, XP, saved course creation, and webhook events.
- Unit tests for error normalization.
- Integration tests for generation lifecycle transitions.
- Tests verifying analytics failures never block product actions.

### Manual event QA

For every release candidate:

1. Run a fresh-account onboarding journey.
2. Complete both catalog and generated-course activation paths.
3. Exercise generation success, validation failure, server failure, and retry.
4. Start, abandon, resume, and complete a lesson.
5. View, dismiss, cancel, fail, and complete a sandbox purchase.
6. Verify event ordering, required parameters, deduplication, and absence of prohibited content.
7. Confirm Crashlytics context and backend correlation IDs.

### Data-quality monitors

- Missing required-property rate.
- Duplicate event-ID rate.
- Client/server completion count mismatch.
- Events with unknown schema versions.
- Impossible ordering, such as lesson completion before lesson start.
- Sudden event-volume changes after releases.

## Delivery sequence

| Milestone | Scope | Exit condition |
|---|---|---|
| M0 | Correctness fixes | No false lesson success, duplicate XP, or silent save success |
| M1 | Analytics/Crashlytics foundation | Sessions, screens, errors, and correlation verified in development |
| M2 | Activation funnel | Signup-to-first-lesson dashboard verified end to end |
| M3 | Creation observability | Stage durations, saves, and failures visible |
| M4 | Lesson analytics | Attempts, abandonment, and completion metrics trustworthy |
| M5 | Subscription lifecycle | Client paywall funnel joined to verified RevenueCat outcomes |
| M6 | Experiments | First activation experiment launched with guardrails |

M0 and the event contract should be completed before broad instrumentation. M1 and backend lifecycle work can then proceed in parallel. Do not begin UX experiments until at least one release has passed event QA and the baseline data is stable.

## Suggested implementation workstreams

### Flutter workstream

- Analytics wrapper and schemas.
- Navigation/session tracking.
- Crashlytics initialization and caught-error reporting.
- Onboarding, create, paywall, lesson, notification, and deep-link instrumentation.
- Lesson retry UX and course lifecycle UI.
- Restore purchases.

### API workstream

- Request IDs and structured logging.
- Server event emitter and schemas.
- Course-generation lifecycle fields and stage timings.
- Transactional/idempotent lesson completion and XP.
- Idempotent saved-course creation.
- RevenueCat webhook endpoint and entitlement synchronization.

### Data/product workstream

- BigQuery exports and modeled funnel tables.
- Activation, creation, lesson, paywall, and reliability dashboards.
- Event dictionary ownership and change review.
- Weekly product review using affected-user counts and funnel changes.

## Definition of done for each event

An event is not complete merely because a logging call exists. It must have:

- A named business question it answers.
- An owner.
- A documented authority: client, server, webhook, or derived.
- Required and optional properties.
- Privacy review.
- Automated schema validation where practical.
- DebugView or warehouse verification.
- Deduplication behavior.
- A dashboard, query, or alert that consumes it.
- Removal or migration instructions when superseded.

## First implementation ticket set

1. Fix lesson persistence success flow and make XP idempotent.
2. Make saved-course creation required and idempotent.
3. Add course lifecycle status and generation IDs.
4. Move podcast generation out of the blocking course-creation path.
5. Persist onboarding subjects and profile selection.
6. Add Firebase Analytics and an `AnalyticsService` wrapper.
7. Add Crashlytics and global error handlers.
8. Add app/session/screen tracking.
9. Implement the activation event contract.
10. Add request correlation across Flutter and Fastify.
11. Implement course-stage timings and creation dashboards.
12. Implement lesson attempt tracking and abandonment derivation.
13. Instrument paywall actions and add Restore Purchases.
14. Add RevenueCat webhook ingestion.
15. Create data-quality checks and release-event QA checklist.

