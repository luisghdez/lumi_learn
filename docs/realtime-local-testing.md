# Talk to Lumi: local voice test

The frontend branch is `enh/speak-to-lumi`; the API branch is `dev`.

## Start locally

Run the API using its existing development environment (`npm run dev`). It needs
`OPENAI_API_KEY`, `TALK_TO_LUMI_REALTIME_ENABLED=true`, and a lesson allow-list
containing `lesson3` (or another lesson being tested). Keep secrets on the server.

From the Flutter project:

```sh
flutter pub get
cd ios
pod update WebRTC-SDK
cd ..
flutter run -d 'iPhone 17 Pro' \
  --dart-define=LUMI_API_BASE_URL=http://localhost:3000 \
  --dart-define=talk_to_lumi_realtime=true
```

For a physical phone, use the Mac's LAN address instead of localhost. The phone
and Mac must be able to reach each other, and the API must listen on the LAN.

Open AP Biology → Unit 2 / Cell Structure and Function → Start with the existing
Force Talk to Lumi tester enabled. Tap **Talk it through (beta)** once. Lumi
invites an explanation; speak normally, then pause. Do not press a button to
finish a conversational turn. **Save live answer** separately requests grading
of the accumulated learner transcript. **End live voice** releases the microphone
without grading, including when the transcript is empty.

## What the diagnostics mean

- API `Talk attempt created; WebRTC signaling pending`: Firestore attempt exists;
  this is not proof of an OpenAI connection.
- API `Talk WebRTC SDP accepted`: OpenAI accepted the offer.
- App peer connected + data channel open + `session.created`: session is ready.
- Increasing `bytesSent` / `totalAudioEnergy`: capture is producing audio.
- `input_audio_buffer.speech_started` → `speech_stopped`: automatic turn detection.
- `conversation.item.input_audio_transcription.completed`: final learner caption.
- `output_audio_buffer.started` → `stopped`: server playback timeline. Confirm
  audibility on the device separately; `response.done` alone is not playback end.

Debug logs contain event names, transcript lengths, and audio statistics, not
transcript text, tokens, or SDP.

## Simulator regression

`flutter_webrtc` 1.6.0 can create an audio track that sends zero samples/packets
on current iOS simulators. Version 1.6.1 includes the simulator-specific audio
module fix. Both Dart and CocoaPods lockfiles must be updated, followed by a
native rebuild; hot reload is insufficient.

Upstream: https://github.com/flutter-webrtc/flutter-webrtc/pull/2140
VAD contract: https://developers.openai.com/api/docs/guides/realtime-vad

A generated spoken fixture can be played through the Mac speakers:

```sh
say -o /tmp/lumi-realtime-test.aiff 'Prokaryotic cells do not have a membrane bound nucleus. Their DNA is in a nucleoid region, and they lack other membrane bound organelles.'
afplay /tmp/lumi-realtime-test.aiff
```

This is an acoustic test, not deterministic microphone injection. Set Simulator
I/O → Audio Input to the Mac microphone. Headphones and echo cancellation can
prevent the generated speaker audio from reaching the input; a human microphone
test is still needed for natural pauses, interruption, and device routing.

## Verified on 2026-09-06

On the iPhone 17 Pro / iOS 26.4 simulator against localhost:3000:

- Before upgrading: peer and data channel connected, but outgoing audio bytes
  and microphone energy remained zero.
- After upgrading: 13,946 outgoing bytes within the initial sampling window,
  followed by increasing microphone energy and packet traffic.
- The generated explanation triggered speech_started, speech_stopped, automatic
  response creation, and a completed 137-character learner transcript. The UI
  showed the correct prokaryotic-cell explanation and Lumi's corresponding reply.
  No stop/finish button was pressed for this turn.
- Save live answer returned score 95 / nextAction retry and displayed 95% in the UI.
- Targeted Flutter analysis, all six existing Flutter tests, TypeScript compilation,
  and the backend Talk feature-gate checks passed. The existing Flutter tests do
  not cover native audio; the acoustic simulator test supplies that evidence.

Remaining observed issue outside audio transport: the assessment's written
feedback suggested moving to Nucleus even though its structured result was
95 / retry. The review model's prose and server-owned progression need to be
aligned before relying on the prose to guide navigation. Physical-device audio
routing and interruption also need a human test.

## Follow-up: replies cut off after a few seconds

Reproduced with a generated question asking for a prokaryotic-cell explanation
and example. The server returned `response.status=incomplete`,
`status_details.reason=max_output_tokens`, and exactly 180 output tokens, with
no speech-start interruption during playback. The response cap was exhausting
the shared audio/text budget.

Raised the session cap from 180 to 1024 while retaining the short-response
instructions. On a newly connected session the same question produced a full
explanation and example, status `completed`, and 566 output tokens. Interruption
remains enabled and the VAD threshold remains 0.5. The frontend now logs response
completion status, reason, and token count without logging spoken content.

For future cutoffs, distinguish `max_output_tokens` from speech-start followed
by playback clearing. Only tune VAD sensitivity or acoustic echo handling when
the latter is observed. Silence duration governs end-of-user-turn detection;
it is not a minimum duration for a valid interruption.
