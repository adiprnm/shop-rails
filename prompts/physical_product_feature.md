## Role

You are an **expert Ruby on Rails engineer and solution architect**.

Your job is to **analyze requirements and produce a concrete implementation plan** for a Rails application.

Do **NOT** write code yet.
Focus on **architecture, data models, flows, edge cases, and responsibilities**.

---

## Background Context

This Rails application currently sells **digital products**.
It will be extended to support **physical products** with shipping.

The checkout flow must dynamically adapt depending on whether the cart contains **at least one physical product**.

---

## Functional Requirements

### 1. Physical Products & Variants

- A physical product **must have at least one variant**
- A user **must select a variant before adding the product to the cart**
- If no variant is selected:
  - Prevent adding to cart
  - Return a clear validation error

---

### 2. Conditional Checkout Fields

When the cart contains **one or more physical products**, the checkout form must additionally require:

- Customer phone number
- Address line
- Province
- City
- District
- Subdistrict
- Order notes

If the cart contains **only digital products**, these fields must be **hidden and not required**.

All checkout fields are **mandatory** except:
- `customer_agree_to_receive_newsletter`
- `order_notes`

---

### 3. Address Data Source (RajaOngkir)

- Province, city, district, and subdistrict data come from **RajaOngkir API**
- The system must **store a local copy** of all retrieved address data
- Once copied, **always use local data** instead of re-fetching

---

### 4. On-Demand Caching Strategy (Addresses)

#### Initial Setup
- Create a script to fetch **all provinces only** from RajaOngkir
- Store provinces locally

#### Runtime Behavior (Lazy Fetching)
- When a province is selected:
  - If cities for that province exist locally → use them
  - Otherwise:
    - Fetch from RajaOngkir
    - Store locally
    - Use the stored copy
- Apply the same logic for:
  - Cities → districts
  - Districts → subdistricts

---

### 5. Address Form UX Rules

- Address fields are `<select>` inputs:
  - Province
  - City
  - District
  - Subdistrict

#### Enable / Disable Logic
- Initially:
  - Only **province** is enabled
  - City, district, subdistrict are disabled
- Selecting a province:
  - Enables city
- Selecting a city:
  - Enables district
- Selecting a district:
  - Enables subdistrict

#### Reset Rules
- If a higher-level field changes:
  - Reset and disable all dependent fields below it

Examples:
- Changing **province** resets city, district, subdistrict
- Changing **city** resets district and subdistrict

---

### 6. Turbo-Driven Interaction

- Use **Turbo Frames** to:
  - Fetch dependent address data
  - Enable/disable fields dynamically
- The checkout experience must behave like a **single-page application**
- No full-page reloads

---

### 7. Shipping Cost Calculation

- When a **subdistrict is selected**:
  - Call RajaOngkir API to calculate **domestic shipping cost**
- Shipping prices must also use **on-demand caching**
  - If a price for the same destination and parameters exists locally → reuse it
  - Otherwise → fetch, store, then use

---

### 8. Browser-Side Auto Fill

- New checkout fields must be cached in the browser using `auto_filler_controller.js`
- This allows returning customers to skip re-entering data
- Follow the **existing implementation pattern** used for:
  - `customer_name`
  - `customer_email_address`

---

### 9. Configuration & Admin Features

- RajaOngkir API key must be:
  - Stored and managed via the **Settings page**
- Products are managed via **Admin UI**
  - Enhance product **create & update forms** to support:
    - Physical product flag
    - Variants
    - Any required shipping-related metadata

---

## Task (Beads-Based Execution)

Instead of printing an implementation plan directly, perform the work using **Beads**
(https://github.com/steveyegge/beads).

### Instructions

- Decompose the work into **clear, atomic beads**
- Each bead must:
  - Represent one concrete implementation concern
  - Be small enough to be implemented independently
  - Have a clear completion definition

### Required Bead Categories

Create beads that collectively cover:

1. **Database & Schema**
   - Tables, columns, constraints, indexes, migrations

2. **Domain Models**
   - Responsibilities, validations, associations, invariants

3. **Checkout Flow Logic**
   - Digital vs physical branching
   - Validation rules
   - Failure modes

4. **RajaOngkir Integration**
   - API boundaries
   - Error handling
   - Rate limiting assumptions

5. **Caching Strategy**
   - Address hierarchy caching
   - Shipping cost caching
   - Cache keys and invalidation rules

6. **Turbo & Frontend Interaction**
   - Turbo Frames responsibilities
   - Reset/enable behavior
   - SPA-like constraints

7. **Admin UI Enhancements**
   - Product form changes
   - Variant management
   - Physical product metadata

8. **Browser Auto-Fill**
   - Fields to persist
   - Lifecycle and invalidation

9. **Edge Cases & Failures**
   - Partial address data
   - API downtime
   - Mixed carts
   - Data inconsistency

### Output Rules

- Do **NOT** include prose explanations outside beads
- Do **NOT** summarize or conclude
- Do **NOT** write code
- Each bead should be written in **Beads markdown format**
- Beads should be suitable for direct tracking and execution

