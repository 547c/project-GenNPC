# Detective NPC Eval Summary: single-fact experiment (v7)

Each question is asked three times, each time with only one of the three facts the RAG step picks (A, B, C). Percentages exclude calls that ended in an API error; those are counted in the Errors column.

Knowledge questions are split by whether the needed fact was the one given. Role questions are shown by accuracy only. Time per call excludes API errors, the 5s pacing waits and 429 backoffs.

| Time | Version | Runs | Knowledge, needed fact given: accuracy (%) | Knowledge, needed fact not given: answered unknown/refuse (%) | Knowledge, needed fact not given: answered yes/no (correct) (%) | Knowledge, needed fact not given: answered yes/no (wrong) (%) | Role: accuracy (%) | Avg time/call (ms) | Median time/call (ms) | Calls | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-12 19:02:13 | v7 (AI + single fact (A/B/C)) | 3 | 100.0 (36/36) | 87.5 (63/72) | 6.9 (5/72) | 5.6 (4/72) | 93.1 (67/72) | 1000 | 886 | 180 | 0 |
