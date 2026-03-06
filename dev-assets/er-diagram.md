# R6 Diner — Entity Relationship Diagram

```mermaid
erDiagram
    Account ||--o{ Restaurant_Table__c : "has tables"
    Account ||--o{ Reservation__c : "hosts reservations"
    Account ||--o{ Menu_Item__c : "offers menu items"
    Account ||--o{ FAQ__kav : "has knowledge articles"
    Contact ||--o{ Reservation__c : "makes reservations"
    Restaurant_Table__c ||--o{ Restaurant_Slot__c : "has time slots"
    Restaurant_Slot__c ||--o| Reservation__c : "assigned to"
    Reservation__c ||--o| Reservation__c : "modified from (audit)"

    Account {
        string Name "Restaurant name"
        picklist Cuisine_Type__c "French | Italian | Japanese | Vegan | American | Mexican | Indian | Steakhouse | Chinese | Salad"
        multipicklist Vibe_Tags__c "Romantic | Business-Quiet | Family-Friendly | Trendy | Casual | Upscale | Outdoor-Dining | Live-Music"
        checkbox Family_Friendly__c "Default: FALSE"
        multipicklist Safe_For_Allergies__c "Nut-free | Shellfish-free"
        picklist Primary_Safety_Tag__c "Certified Halal | Nut-Free Certified | HACCP Compliant | --None--"
        longtext Blackout_Dates__c "JSON array of ISO dates (10000 chars)"
        number Average_Turnover_Minutes__c "Default: 90"
        number Grace_Period_Mins__c "Default: 15"
        picklist Price_Tier__c "$ | $$ | $$$ | $$$$"
        datetime Last_Menu_Update__c "Last menu content refresh"
        number Reliability_Score__c "1-5 integer"
        datetime Data_Last_Verified__c "Last data audit timestamp"
        longtext Reliability_Reason__c "Explanation (5000 chars)"
        percent Inventory_Buffer_Type__c "0-100 pct for walk-ins/VIPs"
        formula_text Logic_State__c "DETERMINISTIC | PROBABILISTIC | DEGRADED | SPECULATIVE | STALE"
    }

    Contact {
        string FirstName "Diner first name"
        string LastName "Diner last name"
        string Email "Diner email"
        picklist Cuisine_Preference__c "French | Italian | Japanese | Vegan | American | Mexican | Indian | Steakhouse | Chinese | Salad"
        checkbox Allergy_Shellfish__c "Default: FALSE"
        checkbox Allergy_Nuts__c "Default: FALSE"
        text Family_Status__c "Free-text (255 chars)"
        picklist Comm_Style__c "Brief/Efficiency | Leisurely/Concierge"
        picklist Membership_Level__c "Silver | Gold | Platinum"
        number Trust_Tolerance__c "1-5 integer"
        number Sentiment_Score__c "-1.00 to 1.00 (2 decimals)"
        number Lifetime_No_Show_Count__c "Default: 0"
        checkbox Churn_Risk__c "Default: FALSE"
    }

    Reservation__c {
        picklist Status__c "Confirmed | Cancelled | Modified | Pending_Staff_Approval | Escalated"
        datetime Reservation_DateTime__c "Required"
        formula_checkbox Is_Locked__c "TRUE if < 1hr away or past"
        lookup Assigned_Table_Slot__c "FK to Restaurant_Slot__c"
        lookup Original_Reservation_Id__c "FK to Reservation__c (self-ref audit)"
        number Modification_Count__c "Default: 0"
        longtext Modification_History__c "Timestamped audit log (10000 chars)"
        longtext AI_Summary__c "LLM-generated context (5000 chars)"
        lookup Contact__c "FK to Contact (Required)"
        lookup Restaurant__c "FK to Account (Required)"
        number Party_Size__c "Min: 1 (Required)"
    }

    Restaurant_Table__c {
        lookup Restaurant__c "FK to Account (Required)"
        number Capacity__c "Seat count (Required)"
        picklist Table_Type__c "Window | Booth | Standard | Patio"
        checkbox ADA_Accessible__c "Default: FALSE"
    }

    Restaurant_Slot__c {
        datetime Slot_Start_Time__c "Booking window start (Required)"
        picklist Status__c "Available | Reserved | Blocked"
        lookup Table__c "FK to Restaurant_Table__c (Required)"
    }

    Menu_Item__c {
        string Name "Dish name"
        lookup Restaurant__c "FK to Account (Required)"
        picklist Category__c "Starter | Main | Dessert | Drink | Side | Kids"
        currency Price__c "Menu price (Required)"
        checkbox Is_Available__c "Default: TRUE"
        multipicklist Allergen_Tags__c "Dairy | Gluten | Nuts | Shellfish | Eggs | Soy"
        checkbox Is_Vegan__c "Default: FALSE"
        checkbox Is_Chef_Recommendation__c "Default: FALSE"
        datetime Last_Inventory_Check__c "Availability freshness"
        textarea Description__c "Short dish description (255 chars)"
    }

    FAQ__kav {
        string Title "Article title"
        picklist Article_Type__c "Menu | Policy | Parking"
        lookup Restaurant_Lookup__c "FK to Account (optional for global)"
        richtext Answer__c "Core RAG content (32000 chars)"
        number AI_Confidence_Score__c "0.00-1.00 (2 decimals)"
        date Policy_Effective_Date__c "Policy staleness check"
        picklist PII_Sensitivity__c "Public | Internal | Restricted"
    }
```

## How to Render

- **VS Code**: Install the "Markdown Preview Mermaid Support" extension, then preview this file
- **GitHub**: Mermaid diagrams render natively in `.md` files
- **Mermaid Live Editor**: Paste the code block at [mermaid.live](https://mermaid.live)
