
Azure Services Being Used

1) Azure Cost Management - allows us to investigate historical expenditure, group costs by resources or services and then view forecasted costs.
2) Azure Budgets - defines how much a certain company is willing to spend within a specific period. Budgets can send alerts but it doesn't automatically stop resources or prevent expenditure from happening
3) Azure Monitor Action Groups - when an alert happens, Action Groups determine whether an alert needs to be generated. A budget threshold can trigger an Action Group.
4) Azure Logic Apps - workflow automation service. It can receive a budget alert, inspect its contents, and then send a formatted notification to a distribution list or Teams channel.
5) Terraform - to deploy it all.


**Azure's cost data** is typically available 8–24 hours after usage, and budgets are generally evaluated every 24 hours, so this isn't a real-time detection system. This is something that needs to be communicated to stakeholders in the solution design phase.


ADRs - Architecture Decision Records

| Decision                  | Our initial approach                 | Rationale                                                                          |
| ------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| Cost visibility           | Native Azure Cost Analysis           | Avoid unnecessary infrastructure                                                   |
| Budget Scope              | 1 sub initially                      | monitor all resources, including accidental deployments outside of a particular RG |
| Notification              | Action Group -> Logic App            | to separate detection from notification processing                                 |
| Infrastructure Deployment | Terraform                            | Reproducibilty + Governance                                                        |
| Source Control            | GitHub                               | Collaboration + Code Reviews                                                       |
| Terraform State           | Dedicated Azure Blob Storage Backend | Shared state + locking capabilities                                                |
| Authn                     | Entra Workload Identity Federation   | Avoiding long-lived federation                                                     |
| Reporting                 | Azure-native first                   | To keep initial costs low                                                          |

NFRs :
1) Azure Well Architected principles
2) least privilege RBAC
3) appropriate Australian Governance Considerations

