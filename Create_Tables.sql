create database Book_shops;
-----------------------------------------------------------------------------
drop table Location;
drop table City;
drop table Book_Store;
drop table Library;
drop table Book;
drop table Libraries_Books;
drop table Publish_Office;
drop table [Format];
drop table Publication_Type;
drop table [Order];
drop table [StatusOrder];
drop table Books_Orders;
drop table Author;
use Book_Shops;
Create table City
(
	ID_City int identity(1,1) constraint City_PK primary key,
	Name nvarchar(50) UNIQUE not null ,
)
Create table Location
(
	ID_Location int identity(1,1) constraint Location_PK primary key,
	ID_City int not null,
	Street nvarchar(50) not null,
	Flat int not null,
	House int not null,
	Postcode int not null,
	Point geography not null,
	FOREIGN KEY(ID_City) REFERENCES [City](ID_City)
)
Create table Book_Store
(
	ID_Book_Store int constraint Book_Store_PK primary key,
	Name nvarchar(30) not null,
	FOREIGN KEY(ID_Book_Store) REFERENCES [Location](ID_Location)
)
Create table Library
(
	ID_Library int constraint Library_PK primary key,
	Amount int default(0)
	FOREIGN KEY(ID_Library) REFERENCES [Book_Store](ID_Book_Store)
)
Create table Publication_Type
(
	ID_Publication_Type int identity(1,1) constraint Publication_Type_PK primary key,
	Type nvarchar(50) UNIQUE not null
)
Create table Publish_Office
(
	ID_Publish_Office int constraint Publish_Office_PK primary key,
	Name nvarchar(50) UNIQUE not null,
	FOREIGN KEY(ID_Publish_Office) REFERENCES [Location](ID_Location)
)
Create table [Format]
(
	ID_Format int identity(1,1) constraint Format_PK primary key,
	[Format] nvarchar(50) UNIQUE not null
)
Create table Book
(
	ID_Book int identity(1,1) constraint Book_PK primary key,
	Name nvarchar(50) not null,
	Description nvarchar(500) not null,
	Price int not null,
	ID_Publication_Type int not null,
	ID_Publishing_Office int not null,
	Size int not null,
	ID_Format int not null,
	Weight int not null,
	Age_Limit int not null,
	FOREIGN KEY(ID_Publication_Type) REFERENCES [Publication_Type](ID_Publication_Type),
	FOREIGN KEY(ID_Publishing_Office) REFERENCES [Publish_Office](ID_Publish_Office),
	FOREIGN KEY(ID_Format) REFERENCES [Format](ID_Format)
)
Create table Libraries_Books
(
	ID_Libraries int FOREIGN KEY REFERENCES Library(ID_Library) not null ,
	ID_Books	 int FOREIGN KEY REFERENCES Book(ID_Book)		not null,
	Amount int not null,		
	constraint Libraries_Books_PK primary key(ID_Libraries,ID_Books)
);
Create table FullName
(
	ID_FullName int identity(1,1) constraint FullName_PK primary key,
	Surname nvarchar(50) not null,
	[Name] nvarchar(50) not null,
	Patronymic nvarchar(50) not null
)
Create table Envelope
(
	ID_Envelope int identity(1,1) constraint Envelope_PK primary key,
	[Url] nvarchar(700) UNIQUE not null
)
Create table Author
(
	ID_Author int identity(1,1) constraint Author_PK primary key,
	ID_FullName int FOREIGN KEY REFERENCES FullName(ID_FullName) not null
)
Create table Authors_Books
(
	ID_Author int	 FOREIGN KEY REFERENCES Author(ID_Author)	not null,
	ID_Books  int	 FOREIGN KEY REFERENCES Book(ID_Book)		not null,
	constraint Authors_Books_PK primary key(ID_Author,ID_Books)
)
Create table Envelopes_Books
(
	ID_Envelope int	 FOREIGN KEY REFERENCES Envelope(ID_Envelope)	not null,
	ID_Books	int	 FOREIGN KEY REFERENCES Book(ID_Book)			not null,
	constraint Envelopes_Books_PK primary key(ID_Envelope,ID_Books)
)
Create table StatusOrder
(
	ID_StatusOrder int identity(1,1) constraint StatusOrder_PK primary key,
	[name] nvarchar(50) UNIQUE not null
)
Create table [Type]
(
	ID_Type int identity(1,1) constraint Type_PK primary key,
	[Type] nvarchar(30) UNIQUE not null
)
Create table [User]
(
	ID_User int constraint User_PK primary key,
	ID_Type int not null,
	ID_FullName int not null,
	[Login] nvarchar(30) UNIQUE not null,
	[Password] nvarchar(30) not null,
	[number] nvarchar(30) not null,
	[mail] nvarchar(60) not null,
	FOREIGN KEY(ID_User) REFERENCES [Location](ID_Location),
	FOREIGN KEY(ID_FullName) REFERENCES [FullName](ID_FullName),
	FOREIGN KEY(ID_Type) REFERENCES [Type](ID_Type)
)
Create table [Order]
(
	ID_Order int identity(1,1) constraint Order_PK primary key,
	ID_StatusOrder int not null,
	ID_User int not null,
	amount int not null,
	FOREIGN KEY(ID_StatusOrder) REFERENCES [StatusOrder](ID_StatusOrder),
	FOREIGN KEY(ID_User) REFERENCES [User](ID_User),
)
Create table Books_Orders
(
	ID_Books	int	 FOREIGN KEY REFERENCES Book(ID_Book)		not null,
	ID_Orders	int	 FOREIGN KEY REFERENCES [Order](ID_Order)	not null,
	[Count] int not null,
	constraint Books_Orders_PK primary key(ID_Orders,ID_Books)
)
Create table BookScore
(
	ID_Users	int	 FOREIGN KEY REFERENCES [User](ID_User)		not null,
	ID_Books	int	 FOREIGN KEY REFERENCES Book(ID_Book)		not null,
	rating		int not null,
	comment		nvarchar(140) not null,
	constraint BookScore_PK primary key(ID_Users,ID_Books)
)


delete from [Location];
DBCC CHECKIDENT('[Location]', RESEED, 0)


Create table BookTemporary
(
	[ID_Book] int identity(1,1) constraint BookTemporary_PK primary key,
	[Name] nvarchar(50) not null,
	[Description] nvarchar(500) not null,
	[Price] int not null,
	[ID_Publication_Type] int not null,
	[ID_Publishing_Office] int not null,
	[Size] int not null,
	[ID_Format] int not null,
	[Weight] int not null,
	[Age_Limit] int not null
)

drop table BookTemporary;