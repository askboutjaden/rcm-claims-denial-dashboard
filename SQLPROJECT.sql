SELECT * FROM claims LIMIT 5;

SELECT claim_status, COUNT(*) AS claim_count
FROM claims
GROUP BY claim_status;

SELECT
  p.payer_name,
  COUNT(*) AS adjudicated_claims,
  SUM(CASE WHEN c.claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
  ROUND(100.0 * SUM(CASE WHEN c.claim_status = 'Denied' THEN 1 ELSE 0 END) / COUNT(*), 1) AS denial_rate_pct
FROM claims c
JOIN payers p ON c.payer_id = p.payer_id
WHERE c.claim_status <> 'Pending'
GROUP BY p.payer_name
ORDER BY denial_rate_pct DESC;

-- Query 3: Top denial reasons by volume and dollars
SELECT
  d.carc_code,
  d.description,
  COUNT(*) AS denied_claims,
  ROUND(SUM(c.billed_amount), 2) AS dollars_at_risk,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM claims WHERE claim_status = 'Denied'), 1) AS pct_of_denials
FROM claims c
JOIN denial_reasons d ON c.denial_carc = d.carc_code
WHERE c.claim_status = 'Denied'
GROUP BY d.carc_code, d.description
ORDER BY denied_claims DESC;

-- Query 4: A/R aging buckets (unpaid claims)
SELECT
  CASE
    WHEN julianday('now') - julianday(submit_date) <= 30 THEN '0-30'
    WHEN julianday('now') - julianday(submit_date) <= 60 THEN '31-60'
    WHEN julianday('now') - julianday(submit_date) <= 90 THEN '61-90'
    ELSE '90+'
  END AS aging_bucket,
  COUNT(*) AS open_claims,
  ROUND(SUM(billed_amount), 2) AS open_ar_dollars,
  ROUND(AVG(julianday('now') - julianday(submit_date)), 0) AS avg_days_out
FROM claims
WHERE claim_status <> 'Paid'
GROUP BY aging_bucket
ORDER BY aging_bucket;

-- Query 5: Appeal overturn rate and dollars recovered
SELECT
  COUNT(*) AS total_appeals,
  SUM(CASE WHEN appeal_outcome = 'Overturned' THEN 1 ELSE 0 END) AS overturned,
  ROUND(100.0 * SUM(CASE WHEN appeal_outcome = 'Overturned' THEN 1 ELSE 0 END) / COUNT(*), 1) AS overturn_rate_pct,
  ROUND(SUM(CAST(recovered_amount AS REAL)), 2) AS total_recovered
FROM appeals;