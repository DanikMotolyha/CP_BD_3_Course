------------------------------------------------------------------------------------------------------------------------------------------
-- INSERT DATA
delete from Location;
delete from Book_Store;
delete from Library;
delete from Libraries_Books;
delete from Publication_Type;
delete from Publish_Office;
delete from Book;
delete from Books_Orders;
delete from [User];
delete from [Order];
delete from [Author];
delete from [Authors_Books];


--������

INSERT INTO City(Name) values (N'�����'); 
INSERT INTO City(Name) values (N'�����'); 
INSERT INTO City(Name) values (N'������'); 
INSERT INTO City(Name) values (N'������'); 
INSERT INTO City(Name) values (N'�������'); 
INSERT INTO City(Name) values (N'�������'); 
INSERT INTO City(Name) values (N'��������'); 
INSERT INTO City(Name) values (N'����������'); 
INSERT INTO City(Name) values (N'����������'); 
INSERT INTO City(Name) values (N'�����');
INSERT INTO City(Name) values (N'�������'); 
INSERT INTO City(Name) values (N'����'); 
INSERT INTO City(Name) values (N'������');
INSERT INTO City(Name) values (N'������');
INSERT INTO City(Name) values (N'������'); 
INSERT INTO City(Name) values (N'����'); 
INSERT INTO City(Name) values (N'���������'); 
INSERT INTO City(Name) values (N'������'); 
INSERT INTO City(Name) values (N'������'); 
INSERT INTO City(Name) values (N'�����');
delete from City;
DBCC CHECKIDENT('City', RESEED, 0)
select * from City order by ID_City;


--������� ������� 
INSERT INTO StatusOrder(name) values(N'������������');
INSERT INTO StatusOrder(name) values(N'��������');
INSERT INTO StatusOrder(name) values(N'�������');
delete from StatusOrder;
DBCC CHECKIDENT('StatusOrder', RESEED, 0)

select * from StatusOrder;

--������ �����
INSERT INTO [Format]([Format]) values(N'������������');
INSERT INTO [Format]([Format]) values(N'�������');
INSERT INTO [Format]([Format]) values(N'�������');
INSERT INTO [Format]([Format]) values(N'�����');
delete from [Format];
DBCC CHECKIDENT('Format', RESEED, 0)

select * from [Format];

--��� ����������
INSERT INTO Publication_Type(type) values(N'�������');
INSERT INTO Publication_Type(type)  values(N'������');
delete from Publication_Type;	
DBCC CHECKIDENT('Publication_Type', RESEED, 0)
select * from Publication_Type;

--��� ������ admin/user
INSERT INTO [Type](type) values(N'�������������');
INSERT INTO [Type](type)  values(N'������������');
delete from [Type];
DBCC CHECKIDENT('[Type]', RESEED, 0)

select * from [Type];

--������� ������� (22 �������� + 5 ����������)
delete from [user];
delete from Books_Orders;
delete from [Order];


delete from [Location];
DBCC CHECKIDENT('[Location]', RESEED, 0)
---��������
--Minsk
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'���������', 150, 80, 220077, geography::Point(53.83458571180885, 27.619545639262995, 4326));
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'�����������', 21, 103, 220046, geography::Point(53.92696711582081, 27.430019054029163, 4326));
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'�������� �������������', 155, 12, 220131, geography::Point(53.93521810492348, 27.6516094886096, 4326));

--�����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(2, N'���. �����������', 33, 44, 220250, geography::Point(52.0968855343548, 23.695955138007314, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(3, N'�����. ���� ������', 26, 3, 230005, geography::Point(53.69721266414067, 23.83511020950841, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(4, N'��������', 38, 9, 246018, geography::Point(52.44723014830731, 30.96178001074009, 4326));
--�������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(5, N'��������', 1, 2, 254001, geography::Point(55.189142510140535, 30.200307038547052, 4326));
--�������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(6, N'�������', 11, 15, 255131, geography::Point(53.89550117073178, 30.3355389707772, 4326));
--��������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(7, N'���. ��������', 36, 2, 220015, geography::Point(53.14782467329587, 29.198512655030875, 4326));
--����������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(8, N'���������', 107, 1, 210578, geography::Point(53.13305995678258, 25.99931106719761, 4326));
--����������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(9, N'���������', 79, 78, 230518, geography::Point(55.53645710629647, 28.652925706790864, 4326));
--�����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(10, N'���������', 9, 5, 250724, geography::Point(52.12611002582478, 26.092549029856876, 4326));
--�������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(11, N'�����. ������������', 27, 54, 210234, geography::Point(54.226524990226444, 28.504246636041763, 4326));
--����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(12, N'8 �����', 14, 3, 240291, geography::Point(53.89788304301813, 25.29223037208526, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(13, N'�������', 8, 11, 210211, geography::Point(52.049057480146004, 29.243183349037356, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(14, N'�������', 5, 3, 270541, geography::Point(55.487904888557125, 28.770203045512382, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(15, N'���������', 49, 2, 250541, geography::Point(53.08844571130099, 25.310997367521928, 4326));
--����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(16, N'����', 48, 3, 240432, geography::Point(54.51338979887965, 30.40054123043841, 4326));
--���������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(17, N'���������', 60, 75, 210133, geography::Point(54.30819333416763, 26.834351541576005, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(18, N'������������', 96, 5, 240491, geography::Point(52.89420984975108, 30.026907051426146, 4326));
--������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(19, N'���������', 9, 1, 220114, geography::Point(52.21319794395197, 24.353638561874913, 4326));
--�����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(20, N'8 �����', 4, 3, 240124, geography::Point(53.02414304495404, 27.554136946200884, 4326));
-- ����� �� ����� ��������� ������� �� ����� �������� ��� �� ���� ��� ����� ����� �����

INSERT INTO Book_Store(ID_Book_Store, name) values(1, N'��������');
INSERT INTO Library(ID_Library)				values(1);
INSERT INTO Book_Store(ID_Book_Store, name) values(2, N'������� �����');
INSERT INTO Library(ID_Library)				values(2);
INSERT INTO Book_Store(ID_Book_Store, name) values(3, N'��������');
INSERT INTO Library(ID_Library)				values(3);
INSERT INTO Book_Store(ID_Book_Store, name) values(4, N'��������');
INSERT INTO Library(ID_Library)				values(4);
INSERT INTO Book_Store(ID_Book_Store, name) values(5, N'������ ����');
INSERT INTO Library(ID_Library)				values(5);
INSERT INTO Book_Store(ID_Book_Store, name) values(6, N'����� �����');
INSERT INTO Library(ID_Library)				values(6);
INSERT INTO Book_Store(ID_Book_Store, name) values(7, N'��� ���������');
INSERT INTO Library(ID_Library)				values(7);
INSERT INTO Book_Store(ID_Book_Store, name) values(8, N'���� �������');
INSERT INTO Library(ID_Library)				values(8);
INSERT INTO Book_Store(ID_Book_Store, name) values(9, N'��� ������');
INSERT INTO Library(ID_Library)				values(9);
INSERT INTO Book_Store(ID_Book_Store, name) values(10, N'�����');
INSERT INTO Library(ID_Library)				values(10);
INSERT INTO Book_Store(ID_Book_Store, name) values(11, N'�������');
INSERT INTO Library(ID_Library)				values(11);
INSERT INTO Book_Store(ID_Book_Store, name) values(12, N'������������� �����');
INSERT INTO Library(ID_Library)				values(12);
INSERT INTO Book_Store(ID_Book_Store, name) values(13, N'�������');
INSERT INTO Library(ID_Library)				values(13);
INSERT INTO Book_Store(ID_Book_Store, name) values(14, N'����������');
INSERT INTO Library(ID_Library)				values(14);
INSERT INTO Book_Store(ID_Book_Store, name) values(15, N'������');
INSERT INTO Library(ID_Library)				values(15);
INSERT INTO Book_Store(ID_Book_Store, name) values(16, N'��������');
INSERT INTO Library(ID_Library)				values(16);
INSERT INTO Book_Store(ID_Book_Store, name) values(17, N'������');
INSERT INTO Library(ID_Library)				values(17);
INSERT INTO Book_Store(ID_Book_Store, name) values(18, N'��� ���������');
INSERT INTO Library(ID_Library)				values(18);
INSERT INTO Book_Store(ID_Book_Store, name) values(19, N'��������');
INSERT INTO Library(ID_Library)				values(19);
INSERT INTO Book_Store(ID_Book_Store, name) values(20, N'�����');
INSERT INTO Library(ID_Library)				values(20);
INSERT INTO Book_Store(ID_Book_Store, name) values(21, N'��������');
INSERT INTO Library(ID_Library)				values(21);
INSERT INTO Book_Store(ID_Book_Store, name) values(22, N'������');
INSERT INTO Library(ID_Library)				values(22);
 --storages
select * from Location 
	inner join Book_Store on Location.ID_Location = Book_Store.ID_Book_Store
	inner join Library on Location.ID_Location = Library.ID_Library;
--end storages
--���������
--"�������" �����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'������', 30, 3, 22011, geography::Point(53.90166953610195, 27.54748960854488, 4326));
--"�������" �����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'�����������������', 2, 3, 220124, geography::Point(53.900554838947436, 27.55165889384399, 4326));
--"����� �����" �����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(2, N'8-� �������� ���.', 9, 3, 240124, geography::Point(52.10812603776614, 23.675829764426624, 4326));
--"�������" �����
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(1, N'���������', 27, 34, 220112, geography::Point(53.89832892532705, 27.545621648873716, 4326));
--"���������� �����" ������
INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point) 
	values(3, N'����������', 16, 3, 223104, geography::Point(53.68587684818648, 23.826558608649766, 4326));

INSERT INTO Publish_Office(ID_Publish_Office, name) values(23, N'�������');
INSERT INTO Publish_Office(ID_Publish_Office, name) values(24, N'�������');
INSERT INTO Publish_Office(ID_Publish_Office, name) values(25, N'����� �����');
INSERT INTO Publish_Office(ID_Publish_Office, name) values(26, N'�������');
INSERT INTO Publish_Office(ID_Publish_Office, name) values(27, N'���������� �����');
delete from [Publish_Office];
DBCC CHECKIDENT('[Publish_Office]', RESEED, 0)
select * from Publish_Office;
delete from Book;
exec GetAllFullName;


exec DeleteAuthor 3;

exec FindNearestStore 'user';

exec FindNearestStoreWithBook N'user', N'���� �������';



exec CreateAuthor N'������',N'��������',N'��������';