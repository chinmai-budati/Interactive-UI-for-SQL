import mysql.connector

def connect_to_db():
    return mysql.connector.connect(
    host="localhost",
    user="root",
    password="Me_chinmai@04",
    database="advanced_sql"
)


def get_basic_info(cursor):
    queries = {
        "Total Suppliers": "select count(*) as total_suppliers from suppliers",
        "Total Products": "select count(*) as total_products from products",
        "Total Categories Dealing": "select count(distinct category) as total_categories from products",
        "Total Sale Value (Last 3 Months)": """
        select round(sum(abs(se.change_quantity)*p.price),2) as total_sales_value_in_last_3_months
        from stock_entries as se
        join products p 
        on p.product_id=se.product_id
        where se.change_type="Sale" 
        and se.entry_date >= (select date_sub(max(entry_date),interval 3 month) from stock_entries)
        """,
        "Total Restock Value (Last 3 Months)": """
        select round(sum(abs(se.change_quantity)*p.price),2) as total_restock_value_in_last_3_months
        from stock_entries as se
        join products p 
        on p.product_id=se.product_id
        where se.change_type="Restock" 
        and se.entry_date >= (select date_sub(max(entry_date),interval 3 month) from stock_entries)
        """,
        "Below Reorder & No pending Reorders": """
        select count(*) from products where stock_quantity < reorder_level
        and product_id not in (select distinct product_id from reorders where status="Pending")
        """
    }

    result = {}
    for label, query in queries.items():
        cursor.execute(query)
        row = cursor.fetchone()
        result[label] = list(row.values())[0]

    return result


def get_tables(cursor):
    queries = {
        "Suppliers Contact Details": "select supplier_name, contact_name, email, phone from suppliers order by supplier_name asc",
        "Products with Suppliers and Stock": """
                                             select p.product_name, s.supplier_name, p.stock_quantity, p.reorder_level
                                             from products as p
                                                      join suppliers s
                                                           on s.supplier_id = p.supplier_id
                                             order by p.product_name asc
                                              """,
        "Products Needing Reorder": "select product_id, product_name, stock_quantity, reorder_level from products where stock_quantity <= reorder_level"
    }

    tables = {}
    for label, query in queries.items():
        cursor.execute(query)
        tables[label] = cursor.fetchall()

    return tables

def get_categories(cursor):
    cursor.execute("select distinct category from products order by category")
    rows = cursor.fetchall()
    return [row["category"] for row in rows]

def get_suppliers(cursor):
    cursor.execute("select supplier_id, supplier_name from suppliers order by supplier_name asc")
    return cursor.fetchall()

def add_new_product(cursor, db, p_name, p_category, p_price, p_stock, p_reorder, p_supplier):
    proc_call = "call AddNewProduct(%s ,%s, %s, %s, %s, %s)"
    params = (p_name, p_category, p_price, p_stock, p_reorder, p_supplier)
    cursor.execute(proc_call, params)
    db.commit()

def get_all_products(cursor):
    cursor.execute("select product_id, product_name from products order by product_name")
    return cursor.fetchall()

def get_product_history(cursor, product_id):
    query = "select * from product_inventory_history where product_id = %s order by record_date desc"
    cursor.execute(query, (product_id,))
    return cursor.fetchall()

def place_reorder(cursor, db, product_id, reorder_quantity):
    query = """
        insert into reorders(reorder_id, product_id, reorder_quantity, reorder_date, status)
        select max(reorder_id)+1, %s, %s, curdate(), "Ordered" from reorders
        """
    cursor.execute(query, (product_id, reorder_quantity))
    db.commit()

def get_pending_reorders(cursor):
    cursor.execute("""select r.reorder_id, p.product_name from reorders r join products p on p.product_id = r.product_id""")
    return cursor.fetchall()

def mark_reorder_as_pending(cursor):
    cursor.callproc("mark_reorder_as_pending", [reorder_id])
    db.commit()