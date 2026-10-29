# Rulebook Eval Summary: Ollama qwen3.5:9b

Local model run (thinking off, temperature 0, seed 42, context 8192). Time per card is the local model call time including regenerations; the first card of a run also includes loading the model.

Broken JSON counts replies that were not valid JSON for the format. Those cards are counted in the Errors column and excluded from accuracy. Context truncated counts replies that hit the context limit or the output limit.

Time per card (average and median) excludes cards that ended in an API error.

Accuracy excludes cards that ended in an API error; those are counted in the Errors column.

Effects and cost accuracy are computed over the cards that should not be rejected. RAG hit rate counts cards whose needed rules were all among the picked rules (RAG versions).

| Time | Version | Runs | Accuracy per run (%) | Avg accuracy (%) | Direct (%) | Paraphrase (%) | Confusing (%) | Condition (%) | Illegal (%) | Trick (%) | Effects accuracy (%) | Cost accuracy (%) | Wrongly rejected | Wrongly passed | RAG hit rate (%) | Regenerations | Code rejections | Avg time/card (ms) | Median time/card (ms) | Errors | Broken JSON | Context truncated |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-10-28 21:08:35 | v2 (AI + all rules) | 3 | 62.9 / 60.0 / 60.0 | 61.0 | 100.0 | 36.4 | 50.0 | 33.3 | 66.7 | 100.0 | 75.0 | 64.3 | 9 | 5 | n/a | 0 | 0 | 36778 | 34050 | 0 | 0 | 0 |
| 2026-10-28 22:11:28 | v9 (AI + embedding RAG rules (split pieces, condition pieces dropped)) | 3 | 60.0 / 60.0 / 60.0 | 60.0 | 83.3 | 72.7 | 16.7 | 33.3 | 80.0 | 50.0 | 78.6 | 64.3 | 0 | 3 | 97.0 | 0 | 0 | 35637 | 34445 | 0 | 0 | 0 |
