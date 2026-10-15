# Rulebook Eval Summary

Time per card is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.

Time per card (average and median) excludes cards that ended in an API error.

Accuracy excludes cards that ended in an API error; those are counted in the Errors column.

Effects and cost accuracy are computed over the cards that should not be rejected. RAG hit rate counts cards whose needed rules were all among the picked rules (v3 and v4 only).

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Direct (%) | Paraphrase (%) | Confusing (%) | Condition (%) | Illegal (%) | Trick (%) | Effects accuracy (%) | Cost accuracy (%) | Wrongly rejected | Wrongly passed | RAG hit rate (%) | Regenerations | Code rejections | Avg time/card (ms) | Median time/card (ms) | Errors |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-12 23:31:52 | v1 (AI only) | 3 | 5.7 / 5.7 / 5.7 | 5.7 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 50.0 | 73.8 | 0.0 | 6 | 15 | n/a | 0 | 0 | 1019 | 929 | 0 |
