# Card Eval Summary

Time per card is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.

Time per card (average and median) excludes cards that ended in an API error.

Accuracy excludes cards that ended in an API error; those are counted in the Errors column.

Effects and cost accuracy are computed over the cards that should not be rejected.

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Normal accuracy (%) | Hard accuracy (%) | Trick accuracy (%) | Effects accuracy (%) | Cost accuracy (%) | Avg time/card (ms) | Median time/card (ms) | Regenerations | Fallbacks | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-06 09:20:34 | v1 (AI only) | 3 | 95.0 / 95.2 / 95.2 | 95.2 | 100.0 | 100.0 | 66.7 | 94.3 | 94.3 | 12035 | 1304 | 0 | 0 | 1 |
| 2026-10-06 09:28:54 | v2 (AI + examples) | 3 | 95.0 / 95.2 / 90.5 | 93.6 | 100.0 | 94.1 | 66.7 | 94.3 | 92.5 | 3053 | 942 | 0 | 0 | 1 |
| 2026-10-06 09:46:49 | v3 (AI + examples + code check) | 3 | 100.0 / 95.2 / 90.5 | 95.2 | 94.4 | 100.0 | 87.5 | 94.2 | 94.2 | 6870 | 973 | 0 | 0 | 4 |
