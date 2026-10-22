# Rulebook Eval Summary

Time per card is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.

Time per card (average and median) excludes cards that ended in an API error.

Accuracy excludes cards that ended in an API error; those are counted in the Errors column.

Effects and cost accuracy are computed over the cards that should not be rejected. RAG hit rate counts cards whose needed rules were all among the picked rules (RAG versions).

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Direct (%) | Paraphrase (%) | Confusing (%) | Condition (%) | Illegal (%) | Trick (%) | Effects accuracy (%) | Cost accuracy (%) | Wrongly rejected | Wrongly passed | RAG hit rate (%) | Regenerations | Code rejections | Avg time/card (ms) | Median time/card (ms) | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-12 23:31:52 | v1 (AI only) | 3 | 5.7 / 5.7 / 5.7 | 5.7 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 50.0 | 73.8 | 0.0 | 6 | 15 | n/a | 0 | 0 | 1019 | 929 | 0 |
| 2026-10-14 20:00:15 | v2 (AI + all rules) | 3 | 93.9 / 97.1 / 97.1 | 96.1 | 100.0 | 100.0 | 77.8 | 100.0 | 100.0 | 100.0 | 95.2 | 95.2 | 3 | 0 | n/a | 0 | 0 | 2589 | 1925 | 2 |
| 2026-10-14 20:14:08 | v3 (AI + RAG rules) | 3 | 91.4 / 91.4 / 91.4 | 91.4 | 94.4 | 90.9 | 72.2 | 100.0 | 100.0 | 100.0 | 91.7 | 89.3 | 7 | 0 | 84.8 | 0 | 0 | 3312 | 3857 | 0 |
| 2026-10-14 20:25:25 | v4 (AI + RAG rules + code check) | 3 | 88.6 / 91.4 / 91.4 | 90.5 | 100.0 | 90.9 | 61.1 | 100.0 | 100.0 | 100.0 | 88.1 | 88.1 | 10 | 0 | 84.8 | 0 | 0 | 1467 | 1056 | 0 |
| 2026-10-14 20:36:18 | v5 (AI + all rules + code check) | 3 | 97.1 / 97.1 / 97.1 | 97.1 | 100.0 | 100.0 | 83.3 | 100.0 | 100.0 | 100.0 | 96.4 | 96.4 | 1 | 0 | n/a | 0 | 0 | 1264 | 1021 | 0 |
| 2026-10-21 21:34:56 | v6 (AI + embedding RAG rules) | 3 | 97.1 / 94.3 / 97.1 | 96.2 | 100.0 | 100.0 | 77.8 | 100.0 | 100.0 | 100.0 | 96.4 | 95.2 | 3 | 0 | 90.9 | 0 | 0 | 1468 | 911 | 0 |
| 2026-10-21 21:45:36 | v7 (AI + embedding RAG rules + code check) | 3 | 94.3 / 94.3 / 97.1 | 95.2 | 100.0 | 100.0 | 72.2 | 100.0 | 100.0 | 100.0 | 94.0 | 94.0 | 3 | 0 | 90.9 | 0 | 0 | 1140 | 925 | 0 |
