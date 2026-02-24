-- 1 Total Suppliers
select count(*) as total_suppliers from suppliers

-- 2 Total Products
select count(*) as total_products from products

-- 3 Total Categories Dealing
select count(distinct category) as total_categories from products

-- 4 Total Sales Value in the last 3 months
select round(sum(abs(se.change_quantity)*p.price),2) as total_sales_value_in_last_3_months
from stock_entries as se
join products p 
on p.product_id=se.product_id
where se.change_type="Sale" 
and se.entry_date >= (select date_sub(max(entry_date),interval 3 month) from stock_entries)

-- 5 Total Restock Value in the last 3 months
select round(sum(abs(se.change_quantity)*p.price),2) as total_restock_value_in_last_3_months
from stock_entries as se
join products p 
on p.product_id=se.product_id
where se.change_type="Restock" 
and se.entry_date >= (select date_sub(max(entry_date),interval 3 month) from stock_entries)

-- 6 Total Reorders that are not Pending
select count(*) from products where stock_quantity < reorder_level
and product_id not in (select distinct product_id from reorders where status="Pending")

-- 7 Supplier and their contact details
select supplier_name, contact_name, email, phone from suppliers order by supplier_name

-- 8 Products with their suppliers and current stock
select p.product_name, s.supplier_name, p.stock_quantity, p.reorder_level from products as p 
join suppliers s
on s.supplier_id=p.supplier_id
order by p.product_name asc

-- 9 Products that need to be reordered
select product_id, product_name, stock_quantity, reorder_level from products where stock_quantity <= reorder_level

-- Task 1: Add a new product to the db
delimiter $$
create procedure AddNewProduct(
	in p_name varchar(250),
    in p_category varchar(100),
    in p_price decimal(10,2),
    in p_stock int,
    in p_reorder int,
    in p_supplier int
    )
Begin 
	declare new_product_id int;
    declare new_shipment_id int;
    declare new_entry_id int;
    
    # Making changes in products table
    # Generate product id
    select max(product_id)+1 into new_product_id from products;
    insert into products(product_id, product_name, category, price, stock_quantity, reorder_level, supplier_id)
    values (new_product_id, p_name, p_category, p_price, p_stock, p_reorder, p_supplier);
    
    # Making  changes in shipments table
    select max(shipment_id)+1 into new_shipment_id from shipments;
    insert into shipments values (new_shipment_id, new_product_id, p_supplier, p_stock, curdate());
    
    # Making changes in stock entries table
    select max(entry_id)+1 into new_entry_id from stock_entries;
    insert into stock_entries values (new_entry_id, new_product_id, p_stock, "Restock", curdate());
    
End $$
delimiter ;

call addnewproduct("Smart Watch", "Electronics",99.99,100,25, 5)
SET SQL_SAFE_UPDATES = 1;
-- 1. Remove the restock entry
delete from stock_entries where product_id = 201;
-- 2. Remove the shipment entry
delete from shipments where product_id = 201;
-- 3. Remove the product itself
delete from products where product_id = 201;

select max(entry_date) from stock_entries

-- Task 2: Product Inventory History(Shipments, Sales and Reorders)
create or replace view product_inventory_history as
select pih.product_id, pih.record_type, pih.record_date, pih.quantity, pih.change_type, pr.supplier_id from
(
select product_id,
"Shipment" as record_type,
shipment_date as record_date,
quantity_received as quantity,
null change_type
from shipments
union all
select product_id,
"Stock Entry" as record_type,
entry_date as record_date,
change_quantity as quantity,
change_type
from stock_entries
)pih
join products pr
on pih.product_id=pr.product_id

select * from product_inventory_history where product_id=123

-- Task 3: Place a Reorder
insert into reorders(reorder_id, product_id, reorder_quantity, reorder_date, status)
select max(reorder_id)+1, 102, 200, curdate(), "Ordered" from reorders

delete from reorders where reorder_id = 501

-- Task 4: Receive reorder
delimiter $$
create procedure MarkReorderAsReceived(in in_reorder_id int)
Begin
	declare prod_id int;
    declare sup_id int;
    declare ship_id int;
    declare ent_id int;
    declare qty int;
    
    start transaction;
    # Get prod_id, qty from reorders
    select product_id, reorder_quantity 
    into prod_id, qty 
    from reorders
    where reorder_id = in_reorder_id;
    
    # Get sup_id from products
    select supplier_id 
    into sup_id
    from products
    where product_id = prod_id;
    
    #Update reorder table to Received
    update reorders
    set status = "Received"
    where reorder_id = in_reorder_id;
    
    # Update quantity in products
    update products
    set stock_quantity = stock_quantity + qty
    where product_id = prod_id;
    
    # Insert record into shipments
    select max(shipment_id)+1 into ship_id from shipments;
    insert into shipments(shipment_id, product_id, supplier_id, quantity_received, shipment_date)
    values (ship_id, prod_id, sup_id, qty, curdate());
    
    # Insert reorder into stock entries
    select max(entry_id)+1 into ent_id from stock_entries;
    insert into stock_entries(entry_id, product_id, change_quantity, change_type, entry_date)
    values (ent_id, prod_id, qty, "Restock", curdate());
    
    commit;
    End $$
    delimiter ;