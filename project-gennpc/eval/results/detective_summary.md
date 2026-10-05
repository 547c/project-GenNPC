# Detective NPC Eval Summary

Time per question is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.

Accuracy excludes questions that ended in an API error; those are counted in the Errors column.

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Knowledge accuracy (%) | Role accuracy (%) | Leaks | Avg time/question (ms) | Regenerations | Fixed-line fallbacks | Retrieval hit rate (%) | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-04 23:13:53 | v1 (AI only) | 3 | 55.0 / 60.0 / 65.0 | 60.0 | 36.1 | 95.8 | 0 | 903 | 0 | 0 | n/a | 0 |
| 2026-10-04 23:20:01 | v2 (AI + all facts) | 3 | 95.0 / 95.0 / 100.0 | 96.7 | 100.0 | 91.7 | 0 | 1216 | 0 | 0 | n/a | 0 |
| 2026-10-04 23:25:49 | v3 (AI + RAG) | 3 | 100.0 / 100.0 / 100.0 | 100.0 | 100.0 | 100.0 | 0 | 871 | 0 | 0 | 94.4 | 1 |
| 2026-10-04 23:32:17 | v4 (AI + RAG + code check) | 3 | 100.0 / 95.0 / 100.0 | 98.3 | 97.2 | 100.0 | 0 | 1140 | 5 | 0 | 94.4 | 0 |
| 2026-10-04 23:46:15 | v4 (AI + RAG + code check) | 3 | 95.0 / 100.0 / 100.0 | 98.3 | 97.2 | 100.0 | 0 | 1134 | 10 | 2 | 94.4 | 0 |
