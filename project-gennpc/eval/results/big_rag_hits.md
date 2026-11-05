# Big rulebook RAG hit rate

Written 2026-11-05 02:35:13. No API calls (cached embeddings). A hit means every needed rule of the card is among the top 5 picked rules. 65 cards have needed rules (A20 has none and is left out).

| Size | Rules | word hit rate (%) | emb hit rate (%) | emb9 hit rate (%) |
| --- | --- | --- | --- | --- |
| 47 | 47 | 61.5 (40/65) | 84.6 (55/65) | 86.2 (56/65) |
| 66 | 66 | 53.8 (35/65) | 78.5 (51/65) | 84.6 (55/65) |
| 132 | 132 | 46.2 (30/65) | 66.2 (43/65) | 72.3 (47/65) |

## Missed cards

- 47 word: A01, A04, A05, A11, A12, A13, A19, B03, B05, B09, B13, B15, B16, B17, B18, B20, C01, C02, C03, C06, C08, C13, C21, C24, C25
- 47 emb: A11, A12, B05, B12, C01, C02, C03, C13, C14, C21
- 47 emb9: A11, B12, C01, C02, C03, C04, C13, C14, C25
- 66 word: A01, A04, A05, A11, A12, A13, A15, A19, B03, B04, B05, B09, B12, B13, B15, B16, B17, B18, B20, C01, C02, C03, C06, C08, C10, C13, C16, C21, C24, C25
- 66 emb: A11, A12, A19, B05, B12, B15, C01, C02, C03, C13, C14, C17, C20, C21
- 66 emb9: A11, B03, B05, C01, C02, C03, C04, C13, C14, C25
- 132 word: A01, A02, A04, A05, A11, A12, A13, A15, A19, B03, B04, B05, B09, B12, B13, B15, B16, B17, B18, B20, C01, C02, C03, C05, C06, C08, C10, C13, C14, C16, C17, C21, C22, C24, C25
- 132 emb: A02, A11, A12, A13, A14, A19, B05, B12, B14, B15, B20, C01, C02, C03, C13, C14, C16, C17, C20, C21, C24, C25
- 132 emb9: A02, A09, A11, A13, A19, B03, B05, B12, B20, C01, C02, C03, C04, C13, C14, C16, C17, C25
