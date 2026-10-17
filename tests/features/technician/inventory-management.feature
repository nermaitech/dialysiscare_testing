Feature: Inventory management
  Technicians and admins can track and manage medical equipment and supply inventory.

  Scenario: View medicine and equipment inventory
    Given I sign in as "technician"
    When I navigate to the Inventory workspace
    Then I see inventory categories:
      | Category            |
      | Medicines           |
      | Dialyzers           |
      | Machines            |
      | Consumables         |
    And I can see current stock levels for each item

  Scenario: Filter inventory by category
    Given I sign in as "technician"
    When I navigate to Inventory
    And I filter by category "Dialyzers"
    Then only dialyzer items are displayed
    And each item shows:
      | Field           |
      | Item name       |
      | Current stock   |
      | Unit price      |
      | Last updated    |

  @skip @unsupported
  Scenario: View inventory transaction history
    Given I sign in as "technician"
    When I select an inventory item
    And I click "View History"
    Then I see transaction history including:
      | Field              |
      | Date               |
      | Type (Add/Remove)  |
      | Quantity           |
      | Reference (Session)|
      | Technician name    |

  Scenario: Calendar-based inventory navigation
    Given I sign in as "technician"
    When I navigate to Inventory
    And I click on calendar date selector
    Then I can navigate to any date in current month
    When I select a previous date "2024-09-15"
    Then inventory levels are shown for that historical date
    And a message indicates "Showing historical data"

  Scenario: Previous month boundary handling
    Given I sign in as "technician"
    When I navigate to Inventory
    And I attempt to view inventory from previous month (September when in October)
    Then I can access the previous month's data
    And I can see month-over-month changes in inventory
    When I navigate back multiple months (12 or more)
    Then appropriate historical data is shown or message indicates limits

  @skip @unsupported
  Scenario: Low stock alerts and notifications
    Given I sign in as "technician"
    When I navigate to Inventory
    And an item has stock below minimum threshold
    Then the item is highlighted or flagged with alert
    And status shows "Low Stock - [actual]/[minimum]"
    When I click on low stock item
    Then I see:
      | Information       |
      | Current stock     |
      | Minimum required  |
      | Reorder point     |
      | Last order date   |

  @skip @unsupported
  Scenario: Equipment expiry date tracking
    Given I sign in as "technician"
    When I navigate to Inventory - Dialyzers
    And I view dialyzer stock
    Then each dialyzer shows:
      | Field         |
      | Stock quantity |
      | Expiry date    |
      | Days until expiry |
    When expiry date is within 30 days
    Then the item is highlighted with expiry warning
    When expiry date has passed
    Then the item is marked as "Expired" and highlighted in red

  @skip @unsupported
  Scenario: Equipment batch tracking
    Given I sign in as "technician"
    When I view dialyzer inventory
    And I select a specific batch
    Then I see batch details:
      | Detail          |
      | Batch number    |
      | Batch quantity  |
      | Expiry date     |
      | In-stock count  |
      | Used in sessions |

  @skip @unsupported
  Scenario: Inventory adjustment (add/remove stock)
    Given I sign in as "technician"
    When I navigate to Inventory
    And I click on an inventory item
    And I click "Adjust Stock"
    Then I see adjustment form with:
      | Field           |
      | Current quantity |
      | Adjustment type |
      | Adjustment qty  |
      | Reason/Notes    |
    When I enter adjustment and reason
    And I save
    Then stock is updated and transaction is logged

  @skip @unsupported
  Scenario: Equipment assignment during session deducts from inventory
    Given I sign in as "technician"
    When I create a new treatment session
    And I select dialyzer from inventory "Active Dialyzer - Qty: 50"
    And I start treatment
    Then inventory is automatically reduced: "Active Dialyzer - Qty: 49"
    And transaction is logged with session reference

  @skip @unsupported
  Scenario: Multi-center inventory visibility for network admin
    Given I sign in as "networkadmin"
    When I navigate to Inventory
    Then I can see inventory from all centers in the network
    And I can filter by center
    When I select "Center A"
    Then inventory for "Center A" only is displayed

  @skip @unsupported
  Scenario: Inventory export for analysis
    Given I sign in as "centeradmin"
    When I navigate to Inventory
    And I click "Export"
    Then I can choose export options:
      | Option           |
      | Date range       |
      | Item categories  |
      | Include history  |
      | Export format (CSV/Excel) |
    When I select options and export
    Then file is downloaded with inventory data

  @skip @unsupported
  Scenario: Stock projection and consumption analytics
    Given I sign in as "centeradmin"
    When I navigate to Inventory Analytics
    Then I see:
      | Metric                  |
      | Daily consumption rate  |
      | Days of supply remaining |
      | Stock projection        |
    When I view 30-day projection
    Then system predicts when stock will run out
    And suggests reorder timing

  @skip @unsupported
  Scenario: Equipment maintenance schedule in inventory
    Given I sign in as "centeradmin"
    When I view machine inventory
    Then each machine shows:
      | Field               |
      | Status              |
      | Last maintenance    |
      | Next maintenance due |
      | Maintenance notes   |
    When maintenance is due soon
    Then item is flagged for maintenance planning

  @skip @unsupported
  Scenario: Inventory discrepancy reporting
    Given I sign in as "centeradmin"
    When I perform physical inventory count
    And I discover discrepancy between system and actual
    And I report the discrepancy
    Then system logs:
      | Detail              |
      | Item                |
      | Expected quantity   |
      | Actual quantity     |
      | Date reported       |
      | Technician name     |
    And admin is notified for investigation
