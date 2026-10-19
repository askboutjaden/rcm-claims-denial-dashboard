SELECT
  p.payer_name,
  COUNT(*) AS adjudicated_claims,
  SUM(CASE WHEN c.claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
  ROUND(100.0 * SUM(CASE WHEN c.claim_status = 'Denied' THEN 1 ELSE 0 END) / COUNT(*), 1) AS denial_rate_pct
FROM claims c
JOIN payers p ON c.payer_id = p.payer_id
WHERE c.claim_status <> 'Pending'
  AND p.payer_type <> 'Self-Pay'
GROUP BY p.payer_name
ORDER BY denial_rate_pct DESC;