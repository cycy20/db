-- q1
select distinct shipname, substr(shipname,1,instr(shipname,'-')-1)
 from 'order'
 where shipname like "%-%"
order by shipname
-- q2
SELECT Id,ShipCountry,
    (
        CASE
            ShipCountry
            WHEN 'USA' THEN 'NorthAmerica'
            WHEN 'Mexico' THEN 'NorthAmerica'
            WHEN 'Canada' THEN 'NorthAmerica'
            ELSE 'OtherPlace'
        END
    ) as Area
FROM 'ORDER'
WHERE Id >= 15445
ORDER BY Id
LIMIT 20
--q3
SELECT CompanyName,ROUND((lt*1.0/al)*100,2)As PER
from
 (SELECT COUNT(*) AS al,CompanyName
 FROM 'Order',Shipper
 WHERE Shipper.Id=ShipVia
 GROUP BY ShipVia)
 NATURAL JOIN
 (SELECT COUNT(*) AS lt,CompanyName
 FROM 'Order',Shipper
 WHERE Shipper.Id=ShipVia
      AND ShippedDate > RequiredDate
 GROUP BY ShipVia)
order by PER
-- q4
SELECT C.CategoryName,count(*)NUM,Round(avg(P.UnitPrice),2)AVG,
min(P.UnitPrice)MIN,max(P.UnitPrice)MAX,Sum(P.UnitsOnOrder)SUM,C.Id
FROM Product P,Category C
WHERE C.Id=P.CategoryId
GROUP BY P.CategoryId
HAVING count(*)>10
Order BY C.Id DESC
-- q5
select productname, companyname, contactname from(
select P.productname, min(O.orderdate), customerid
from product as P, orderdetail as OD, 'order' as O
where P.discontinued = 1 and P.id = OD.productid and OD.orderid = O.id
group by P.productname
order by P.productname 
), customer as C
where customerid = C.id
-- q6
SELECT a.Id,a.OrderDate,
lag(OrderDate,1,OrderDate) OVER(Order BY OrderDate) as Previous,
round(julianday((a.OrderDate))-julianday(lag(OrderDate,1,OrderDate) OVER(Order BY OrderDate)),2) as Differ
FROM(
    SELECT o.Id,o.OrderDate
    FROM `Order` o
    WHERE o.CustomerId='BLONP'
    Order BY OrderDate
) a
Order BY OrderDate
LIMIT 10
-- q7
select companyname, customerid, exp from(
select companyname, customerid, exp,
ntile(4) over (
    order by exp asc
) as ntile from(
	select companyname, all_c.customerid , round(sum(unitprice * quantity), 2) as exp 
	from(
		select ifnull(companyname, 'MISSING_NAME') as companyname, customerid from(
			select distinct customerid
			from 'order'
		) as O left outer join customer as C on C.id = O.customerid
	) as all_c, 'order' as O, orderdetail as OD 
	where all_c.customerid = O.customerid and O.id = OD.orderid
	group by all_c.customerid
)
)
where ntile = 1
--q8
SELECT r.RegionDescription,e.FirstName,e.LastName,max(e.BirthDate)
FROM EmployeeTerritory et,Employee e,Territory t,Region r
WHERE et.EmployeeId=e.Id and et.TerritoryId=t.Id and t.RegionId=r.Id
GROUP BY r.Id