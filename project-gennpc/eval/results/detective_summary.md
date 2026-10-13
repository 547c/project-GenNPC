# Detective NPC Eval Summary

Time per question is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.

Time per question (average and median) excludes questions that ended in an API error.

Accuracy excludes questions that ended in an API error; those are counted in the Errors column.

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Knowledge accuracy (%) | Role accuracy (%) | Leaks | Avg time/question (ms) | Median time/question (ms) | Regenerations | Fixed-line fallbacks | Retrieval hit rate (%) | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-04 23:13:53 | v1 (AI only) | 3 | 55.0 / 60.0 / 65.0 | 60.0 | 36.1 | 95.8 | 0 | 903 | 859 | 0 | 0 | n/a | 0 |
| 2026-10-04 23:20:01 | v2 (AI + all facts) | 3 | 95.0 / 95.0 / 100.0 | 96.7 | 100.0 | 91.7 | 0 | 1216 | 828 | 0 | 0 | n/a | 0 |
| 2026-10-04 23:25:49 | v3 (AI + RAG) | 3 | 100.0 / 100.0 / 100.0 | 100.0 | 100.0 | 100.0 | 0 | 882 | 856 | 0 | 0 | 94.4 | 1 |
| 2026-10-04 23:32:17 | v4 (AI + RAG + code check) | 3 | 100.0 / 95.0 / 100.0 | 98.3 | 97.2 | 100.0 | 0 | 1140 | 1048 | 5 | 0 | 94.4 | 0 |
| 2026-10-04 23:46:15 | v4 (AI + RAG + code check) | 3 | 95.0 / 100.0 / 100.0 | 98.3 | 97.2 | 100.0 | 0 | 1134 | 935 | 10 | 2 | 94.4 | 0 |
| 2026-10-12 18:34:44 | v5 (AI + RAG (1 fact)) | 3 | 90.0 / 95.0 / 95.0 | 93.3 | 91.7 | 95.8 | 0 | 837 | 811 | 0 | 0 | 83.3 | 0 |
| 2026-10-12 18:44:19 | v6 (AI + RAG (2 facts)) | 3 | 95.0 / 100.0 / 100.0 | 98.3 | 100.0 | 95.8 | 0 | 4727 | 4807 | 0 | 0 | 94.4 | 1 |
