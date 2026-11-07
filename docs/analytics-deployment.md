# Product analytics deployment and verification

This is the implementation companion to `product-analytics-execution-plan.md`. Client events go to Firebase Analytics; crashes and nonfatal failures go to Crashlytics. Authoritative course, save, lesson, API-error, and subscription events go to the API's Firestore `analyticsEvents` collection. RevenueCat delivery receipts are deduplicated in `revenueCatWebhookEvents`.

## Activation verification (November 6, 2026)

- Normal builds leave onboarding preview off. Explicit previews use `--dart-define=FORCE_ONBOARDING_PREVIEW=true`.
- The dev-based PR aligns the iOS minimum deployment target to 15 and the purchase SDK to 10.13.1, matching main and the current Xcode toolchain. The existing app version is preserved.
- AP catalog navigation requires a successful save and successful lesson load. A failed request keeps the learner on the current screen and allows retry.
- Onboarding passes the chosen profile name to the persisted onboarding update, then launches up to five non-speaking activities from the first incomplete lesson.
- Lesson victory waits for server persistence; retries reuse the lesson attempt ID and only apply server-awarded XP.
- Server `lesson_completed.isFirstLesson` means the learner's first recorded saved-course lesson completion, not `lessonId == lesson1`. The first transaction checks existing saved progress and analytics history for legacy accounts, then persists `hasCompletedLesson` and first-completion metadata. Subsequent completions read the marker. Deleted historical data cannot be reconstructed.
- `flutter test` covers controller flow, quick-start question selection, client event emission, failed saves/loads, and completion retry behavior. Backend `npm test` runs the webhook unit checks.
- The API includes `npm run verify:activation`, an opt-in authenticated HTTP integration check. Start the local API with `DISABLE_BACKGROUND_JOBS=1 npm run dev`; provide `FIREBASE_WEB_API_KEY` from Firebase's public client configuration and set `LUMI_ACTIVATION_TEST_ALLOW_REMOTE=1` if using the configured remote Firebase project. It creates a disposable QA account, checks AP discovery/save/loading, onboarding persistence, completion/retries, legacy activation, and invalid completion; finally removes its account, events, and save and reverses its saved-count increment. It targets localhost only.

Deploy the companion API changes before distributing the Flutter build. Firebase Analytics DebugView ingestion, Crashlytics symbolication, and RevenueCat delivery still require the deployment checks below; passing local tests does not verify those external dashboards.

## Event ownership

| Question | Client event | Authoritative server event |
| --- | --- | --- |
| Where do users leave onboarding? | `onboarding_started`, `onboarding_step_completed`, `onboarding_completed` | User `onboardingCompletedAt`, `onboardingCourseIds` |
| Do users submit a course and get it saved? | `course_create_submitted`, `course_generation_submitted`, `course_generation_completed_client`, `course_generation_failed_client` | `course_saved`, `course_generation_completed`, `course_generation_failed`; course `generationStatus` |
| How long until the first lesson is finished? | `lesson_started`, `question_viewed`, `question_answered`, `lesson_completed_client` | `lesson_completed` with `isFirstLesson`, `lessonOrdinal`, `durationMs`, `xpAwarded`; saved-course `completedAt` |
| Why does a purchase not complete? | `paywall_viewed`, `paywall_dismissed`, `purchase_started`, `purchase_cancelled`, `purchase_failed`, `purchase_pending`, `purchase_succeeded` | `subscription_webhook_received`; deduplicated RevenueCat receipt |
| What breaks? | `action_failed`, Crashlytics | `api_request_failed`, course `failureStage` |

Do not infer payment or saved-course conversion from client success events; use the server event or RevenueCat receipt. Join client and server data on Firebase UID (`user_id` / `userId`), course ID, and generation/lesson attempt ID where present. Firebase Analytics exports and Firestore events are separate sources until configured in the data warehouse.

## Required deployment configuration

1. Enable Firebase Analytics and Crashlytics for the iOS/Android Firebase apps, including their native build integrations. Release a build and verify a test `session_started` and a nonfatal error in DebugView/Crashlytics. Do not use production PII in test events.
2. Set `REVENUECAT_WEBHOOK_AUTH_HEADER` to a long random `Authorization` header value in the API deployment secret store. Set the exact same header in RevenueCat's webhook integration and direct it to `POST /webhooks/revenuecat`. The endpoint deliberately returns 503 until a secret is configured. Configure production and sandbox delivery as desired; sandbox receipts are stored but do not change `isPremium`.
3. Ensure RevenueCat's app user ID is the Firebase UID. The Flutter auth controller calls `Purchases.logIn(uid)`. Confirm the configured entitlement ID is exactly `Pro` before turning on webhook synchronization.
4. Enable Firebase Analytics → BigQuery export and a Firestore-to-BigQuery pipeline for `analyticsEvents` (or an equivalent ETL). Limit raw event access to analytics operators; dashboards should use aggregated views. Set retention and deletion policies before broad rollout.
5. Create dashboards for activation (auth → onboarding → course saved → first lesson), generation latency/failure by stage, question abandonment, paywall conversion, and API/Crashlytics errors. Use server events as conversion denominators after a client action.

## Verification checklist

- New account: check `auth_succeeded`, every onboarding step, persisted onboarding completion, and selected course IDs.
- Generated course: observe `course_generation_submitted`, a single `course_saved`, `course_generation_completed`, status `ready`, and one slot increment. Trigger a failure and check status `failed` plus `failureStage`.
- Save the same shared course twice: one saved-course document, one `course_saved`, and one `savedCount` increment.
- Complete a lesson twice or retry after a lost response: one XP award, one `lesson_completed`, and `wasPreviouslyCompleted: true` on retry. Confirm completion screen does not appear after a failed save.
- Open and dismiss each paywall; select unavailable product; cancel a store purchase; complete a sandbox purchase. Confirm the corresponding client event without raw payment data.
- Send the same signed RevenueCat webhook twice: second response has `duplicate: true` and no second entitlement update. An incorrect header returns 401. Sandbox receipts must not change `isPremium`.
- Force an API 4xx/5xx and a client nonfatal error: verify request ID, route template, action, and error code without email, answers, file names, or free-text content.

Automated checks cover compilation and the available Flutter suite plus RevenueCat header/entitlement mapping. Firestore transaction behavior, store purchase flows, dashboard ingestion, and native Crashlytics symbolication require a deployed test environment and credentials; do not mark them verified from local builds alone.

RevenueCat webhook event fields and authentication behavior follow the [official webhook documentation](https://www.revenuecat.com/docs/integrations/webhooks) and [event schema](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields).
