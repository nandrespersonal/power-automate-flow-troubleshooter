# Diagnosis guide

## Data to collect

- Run URL
- Status
- Start/end time
- Duration
- Failed action names
- Error codes/messages
- Inputs/outputs summary
- Loop repetition failures

## Common categories

| Category | Signals | Operator action |
| --- | --- | --- |
| Authentication | 401, token, unauthorized, connection not found | Check connector connection, credential, app registration, cert, or service account |
| Authorization | 403, forbidden, access denied | Check RBAC, permissions, environment access, connector permissions |
| Excel/table/schema | table not found, column missing, invalid row, workbook locked | Check workbook, table schema, file locks, column names |
| Teams posting | Teams connector errors, channel/message not found | Check team/channel/message link and connector auth |
| HTTP/API | 4xx/5xx from called service | Check target API logs and request payload |
| Expression/data shape | template language errors, null property, invalid array/object | Inspect action inputs and upstream Compose/Parse JSON actions |
| Loop child failure | run failed but top-level actions succeeded | Inspect repetitions and child actions |
| Timeout/throttling | timed out, 429, retry-after | Check service health, retry policy, concurrency, throttling |

## Output style

Lead with:

```text
Likely failure category:
Evidence:
Immediate operator action:
Escalation target:
```

