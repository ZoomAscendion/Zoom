_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze layer data mapping for Inventory Management System in Medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping - Inventory Management System

## Overview
This document defines the data mapping between source systems and the Bronze layer in the Medallion architecture for the Inventory Management System. The Bronze layer preserves raw data structure with minimal transformation, ensuring data lineage and auditability.

## Data Mapping Tables

### Products Table Mapping
| Target Layer | Target Table      | Target Field      | Source Layer | Source Table | Source Field      | Transformation Rule |
|--------------|-------------------|-------------------|--------------|--------------|-------------------|-----------------|
| Bronze       | bronze_products   | product_id        | Raw          | raw_products | product_id        | 1-1 Mapping     |
| Bronze       | bronze_products   | product_name      | Raw          | raw_products | product_name      | 1-1 Mapping     |
| Bronze       | bronze_products   | product_code      | Raw          | raw_products | product_code      | 1-1 Mapping     |
| Bronze       | bronze_products   | category_id       | Raw          | raw_products | category_id       | 1-1 Mapping     |
| Bronze       | bronze_products   | unit_price        | Raw          | raw_products | unit_price        | 1-1 Mapping     |
| Bronze       | bronze_products   | cost_price        | Raw          | raw_products | cost_price        | 1-1 Mapping     |
| Bronze       | bronze_products   | description       | Raw          | raw_products | description       | 1-1 Mapping     |
| Bronze       | bronze_products   | supplier_id       | Raw          | raw_products | supplier_id       | 1-1 Mapping     |
| Bronze       | bronze_products   | reorder_level     | Raw          | raw_products | reorder_level     | 1-1 Mapping     |
| Bronze       | bronze_products   | status            | Raw          | raw_products | status            | 1-1 Mapping     |
| Bronze       | bronze_products   | created_date      | Raw          | raw_products | created_date      | 1-1 Mapping     |
| Bronze       | bronze_products   | updated_date      | Raw          | raw_products | updated_date      | 1-1 Mapping     |

### Inventory Table Mapping
| Target Layer | Target Table       | Target Field       | Source Layer | Source Table  | Source Field       | Transformation Rule |
|--------------|--------------------|--------------------|--------------|---------------|--------------------|-------------------|
| Bronze       | bronze_inventory   | inventory_id       | Raw          | raw_inventory | inventory_id       | 1-1 Mapping       |
| Bronze       | bronze_inventory   | product_id         | Raw          | raw_inventory | product_id         | 1-1 Mapping       |
| Bronze       | bronze_inventory   | warehouse_id       | Raw          | raw_inventory | warehouse_id       | 1-1 Mapping       |
| Bronze       | bronze_inventory   | quantity_on_hand   | Raw          | raw_inventory | quantity_on_hand   | 1-1 Mapping       |
| Bronze       | bronze_inventory   | quantity_reserved  | Raw          | raw_inventory | quantity_reserved  | 1-1 Mapping       |
| Bronze       | bronze_inventory   | quantity_available | Raw          | raw_inventory | quantity_available | 1-1 Mapping       |
| Bronze       | bronze_inventory   | last_updated       | Raw          | raw_inventory | last_updated       | 1-1 Mapping       |
| Bronze       | bronze_inventory   | location_code      | Raw          | raw_inventory | location_code      | 1-1 Mapping       |
| Bronze       | bronze_inventory   | batch_number       | Raw          | raw_inventory | batch_number       | 1-1 Mapping       |
| Bronze       | bronze_inventory   | expiry_date        | Raw          | raw_inventory | expiry_date        | 1-1 Mapping       |

### Suppliers Table Mapping
| Target Layer | Target Table      | Target Field      | Source Layer | Source Table | Source Field      | Transformation Rule |
|--------------|-------------------|-------------------|--------------|--------------|-------------------|-----------------|
| Bronze       | bronze_suppliers  | supplier_id       | Raw          | raw_suppliers| supplier_id       | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | supplier_name     | Raw          | raw_suppliers| supplier_name     | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | contact_person    | Raw          | raw_suppliers| contact_person    | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | email             | Raw          | raw_suppliers| email             | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | phone             | Raw          | raw_suppliers| phone             | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | address           | Raw          | raw_suppliers| address           | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | city              | Raw          | raw_suppliers| city              | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | state             | Raw          | raw_suppliers| state             | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | country           | Raw          | raw_suppliers| country           | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | postal_code       | Raw          | raw_suppliers| postal_code       | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | payment_terms     | Raw          | raw_suppliers| payment_terms     | 1-1 Mapping     |
| Bronze       | bronze_suppliers  | status            | Raw          | raw_suppliers| status            | 1-1 Mapping     |

### Categories Table Mapping
| Target Layer | Target Table       | Target Field       | Source Layer | Source Table  | Source Field       | Transformation Rule |
|--------------|--------------------|--------------------|--------------|---------------|--------------------|-------------------|
| Bronze       | bronze_categories  | category_id        | Raw          | raw_categories| category_id        | 1-1 Mapping       |
| Bronze       | bronze_categories  | category_name      | Raw          | raw_categories| category_name      | 1-1 Mapping       |
| Bronze       | bronze_categories  | parent_category_id | Raw          | raw_categories| parent_category_id | 1-1 Mapping       |
| Bronze       | bronze_categories  | description        | Raw          | raw_categories| description        | 1-1 Mapping       |
| Bronze       | bronze_categories  | status             | Raw          | raw_categories| status             | 1-1 Mapping       |
| Bronze       | bronze_categories  | created_date       | Raw          | raw_categories| created_date       | 1-1 Mapping       |

### Warehouses Table Mapping
| Target Layer | Target Table       | Target Field    | Source Layer | Source Table  | Source Field    | Transformation Rule |
|--------------|--------------------|-----------------|--------------|--------------|-----------------|-----------------|
| Bronze       | bronze_warehouses  | warehouse_id    | Raw          | raw_warehouses| warehouse_id    | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | warehouse_name  | Raw          | raw_warehouses| warehouse_name  | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | address         | Raw          | raw_warehouses| address         | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | city            | Raw          | raw_warehouses| city            | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | state           | Raw          | raw_warehouses| state           | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | country         | Raw          | raw_warehouses| country         | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | postal_code     | Raw          | raw_warehouses| postal_code     | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | manager_id      | Raw          | raw_warehouses| manager_id      | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | capacity        | Raw          | raw_warehouses| capacity        | 1-1 Mapping     |
| Bronze       | bronze_warehouses  | status          | Raw          | raw_warehouses| status          | 1-1 Mapping     |

### Purchase Orders Table Mapping
| Target Layer | Target Table            | Target Field      | Source Layer | Source Table       | Source Field      | Transformation Rule |
|--------------|-------------------------|-------------------|--------------|--------------------|--------------------|-------------------|
| Bronze       | bronze_purchase_orders  | po_id             | Raw          | raw_purchase_orders| po_id             | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | po_number         | Raw          | raw_purchase_orders| po_number         | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | supplier_id       | Raw          | raw_purchase_orders| supplier_id       | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | order_date        | Raw          | raw_purchase_orders| order_date        | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | expected_date     | Raw          | raw_purchase_orders| expected_date     | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | total_amount      | Raw          | raw_purchase_orders| total_amount      | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | status            | Raw          | raw_purchase_orders| status            | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | created_by        | Raw          | raw_purchase_orders| created_by        | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | approved_by       | Raw          | raw_purchase_orders| approved_by       | 1-1 Mapping       |
| Bronze       | bronze_purchase_orders  | warehouse_id      | Raw          | raw_purchase_orders| warehouse_id      | 1-1 Mapping       |

### Purchase Order Items Table Mapping
| Target Layer | Target Table                 | Target Field    | Source Layer | Source Table            | Source Field    | Transformation Rule |
|--------------|------------------------------|-----------------|--------------|-------------------------|-----------------|-------------------|
| Bronze       | bronze_purchase_order_items  | po_item_id      | Raw          | raw_purchase_order_items| po_item_id      | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | po_id           | Raw          | raw_purchase_order_items| po_id           | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | product_id      | Raw          | raw_purchase_order_items| product_id      | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | quantity        | Raw          | raw_purchase_order_items| quantity        | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | unit_price      | Raw          | raw_purchase_order_items| unit_price      | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | total_price     | Raw          | raw_purchase_order_items| total_price     | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | received_qty    | Raw          | raw_purchase_order_items| received_qty    | 1-1 Mapping       |
| Bronze       | bronze_purchase_order_items  | status          | Raw          | raw_purchase_order_items| status          | 1-1 Mapping       |

### Stock Movements Table Mapping
| Target Layer | Target Table           | Target Field      | Source Layer | Source Table      | Source Field      | Transformation Rule |
|--------------|------------------------|-------------------|--------------|-------------------|-------------------|-----------------|
| Bronze       | bronze_stock_movements | movement_id       | Raw          | raw_stock_movements| movement_id       | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | product_id        | Raw          | raw_stock_movements| product_id        | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | warehouse_id      | Raw          | raw_stock_movements| warehouse_id      | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | movement_type     | Raw          | raw_stock_movements| movement_type     | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | quantity          | Raw          | raw_stock_movements| quantity          | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | movement_date     | Raw          | raw_stock_movements| movement_date     | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | reference_id      | Raw          | raw_stock_movements| reference_id      | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | reference_type    | Raw          | raw_stock_movements| reference_type    | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | notes             | Raw          | raw_stock_movements| notes             | 1-1 Mapping     |
| Bronze       | bronze_stock_movements | created_by        | Raw          | raw_stock_movements| created_by        | 1-1 Mapping     |

## Data Ingestion Guidelines

### Data Type Compatibility
- All data types are preserved as-is from source systems
- String fields maintain original length constraints
- Numeric fields preserve precision and scale
- Date/DateTime fields maintain original format
- Boolean fields preserved as source format

### Metadata Management
- Each Bronze table includes system metadata columns:
  - `_source_file`: Source file name
  - `_ingestion_timestamp`: Data ingestion timestamp
  - `_batch_id`: Batch identifier for data lineage
  - `_row_hash`: Row-level checksum for change detection

### Data Validation Rules
- Schema validation: Ensure source data matches expected schema
- Data type validation: Verify data types match target schema
- Null value handling: Preserve null values as-is
- Duplicate detection: Log duplicates but preserve all records

### Delta Table Configuration
- Enable Change Data Feed for audit trail
- Set appropriate partition strategy based on data volume
- Configure retention policies for historical data
- Enable optimize and vacuum operations

## Assumptions
- Source systems provide data in structured format (CSV, JSON, Parquet)
- Data ingestion follows batch processing pattern
- No real-time streaming requirements for initial implementation
- Source data quality issues will be addressed in Silver layer
- All source tables have primary key constraints

## Notes
- Bronze layer maintains complete data lineage from source to target
- No business transformations applied at Bronze layer
- Data cleansing and validation deferred to Silver layer
- All source data preserved for audit and compliance requirements