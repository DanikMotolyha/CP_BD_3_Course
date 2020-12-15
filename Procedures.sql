-- this turns on advanced options and is needed to configure xp_cmdshell
sp_configure 'show advanced options', '1'
RECONFIGURE
-- this enables xp_cmdshell
sp_configure 'xp_cmdshell', '1' 
RECONFIGURE
---------------------------------------------------------------------------
--������/�������
--d:\Study\JAVA\XMl_Parser\other.
-- ���������� ������ d:\data.xml ��� 
---------------------------------------------------------------------------
DROP PROCEDURE ParseBooks;
GO
CREATE PROCEDURE [dbo].[ParseBooks]
AS
Begin
	declare @xml xml;
	select @xml=(SELECT CONVERT(XML, BulkColumn) AS BulkColumn
	FROM OPENROWSET(BULK 'd:\Study\JAVA\XMl_Parser\other.xml', SINGLE_BLOB) AS x);
	insert into BookTemporary(
	[Name],
	Price,
	[Description],
	ID_Publication_Type,
	ID_Publishing_Office,
	Size,
	ID_Format,
	[Weight],
	Age_Limit
)
select
P.K.value('Name[1]', 'nvarchar(MAX)') as [Name],
P.K.value('Price[1]', 'bigint') as Price,
P.K.value('Description[1]', 'nvarchar(MAX)') as [Description],
P.K.value('ID_Publication_Type[1]', 'bigint') as [ID_Publication_Type],
P.K.value('ID_Publishing_Office[1]', 'bigint') as [ID_Publishing_Office],
P.K.value('Size[1]', 'bigint') as [Size],
P.K.value('ID_Format[1]', 'bigint') as [ID_Format],
P.K.value('Weight[1]', 'bigint') as [Weight],
P.K.value('Age_Limit[1]', 'bigint') as [Age_Limit]
from @xml.nodes('/Root/Book') as P(K);
WITH C AS
(
  SELECT *, ROW_NUMBER() OVER(PARTITION BY BookTemporary.[Name] ORDER BY (SELECT NULL)) AS n
  FROM BookTemporary
)
SELECT [Name],Price,[Description],ID_Publication_Type,ID_Publishing_Office,
		Size,ID_Format,[Weight],Age_Limit 
INTO BookTemp
FROM C 
WHERE n = 1;
insert into Book([Name],Price,[Description],ID_Publication_Type,ID_Publishing_Office,
	Size,ID_Format,[Weight],Age_Limit) select 
	BookTemp.[Name],BookTemp.Price,BookTemp.[Description],BookTemp.ID_Publication_Type,
	BookTemp.ID_Publishing_Office,BookTemp.Size,BookTemp.ID_Format,BookTemp.[Weight],BookTemp.Age_Limit
	from BookTemp left join Book on Book.Name = BookTemp.Name
		Where Book.Name is null;
drop table BookTemp;
delete from  BookTemporary;
end;
RETURN 0
Go
---------------------------------------------------------------------------
--������� � ����
DROP PROCEDURE ExportToFile;
GO
CREATE PROCEDURE ExportToFile
AS
	SELECT [Name],
	Price,
	[Description],
	ID_Publication_Type,
	ID_Publishing_Office,
	Size,
	ID_Format,
	[Weight],
	Age_Limit
	FROM Book FOR XML PATH('Book'), ROOT('Root');
GO
---------------------------------------------------------------------------
--����� ��������� �������� � ����
DROP PROCEDURE ExecExport;
GO
CREATE PROCEDURE ExecExport
AS
DECLARE @cmd nvarchar(200);
SET @cmd = 'BCP "EXEC Book_shops.dbo.ExportToFile" queryout "d:\data.xml" -S (LocalDB)\MSSQLLocalDB -w -C1251 -r -T';
EXEC master.dbo.xp_cmdshell @cmd;
GO
---------------------------------------------------------------------------
-- ����� ���������� ��������
DROP PROCEDURE FindNearestStore;
GO
CREATE PROCEDURE FindNearestStore
	@login NVARCHAR(30)
AS
BEGIN
	BEGIN TRY
		DECLARE @check INT;
		SELECT @check = ID_User FROM [User] WHERE Login = @login;
		IF(@check > 0)
		BEGIN
			DECLARE @userPoint geography;
			SELECT @userPoint  = Point FROM [Location] WHERE ID_Location = @check;
			select TOP 3 @userPoint.STDistance(Point) as distance, 
			Book_Store.Name as Store, City.Name as City, Location.Street, Location.House, Location.Flat 
				from [Location] inner join Book_Store on Book_Store.ID_Book_Store = Location.ID_Location
					inner join City on Location.ID_City = City.ID_City
						ORDER BY distance;
		END;
		ELSE SELECT N'������ ������� �� ����������!';
	END TRY
	BEGIN CATCH
		SELECT N'������ �������!';
	END CATCH;
END
GO
---------------------------------------------------------------------------
--�������� user
DROP PROCEDURE CreateUser;
GO
CREATE PROCEDURE CreateUser
	@login NVARCHAR(30),
	@name NVARCHAR(30),
	@sername NVARCHAR(30),
	@Patronymic NVARCHAR(30),
	@Password NVARCHAR(30),
	@number NVARCHAR(30),
	@mail NVARCHAR(60),
	@ID_City int,
	@Street nvarchar(50),
	@Flat int,
	@House int,
	@Postcode int,
	@latitude FLOAT,
	@longitude FLOAT
AS
BEGIN
	DECLARE @mess NVARCHAR(200), @Point geography;
	SET @Point = geography::Point(@latitude, @longitude, 4326);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @id_city_find int, @checkFullName int, @id_User int, @id_fullName int;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		if(@checkLogin = 0)
		BEGIN
			SELECT @id_city_find = ID_City from City where ID_City = @ID_City;
			if(@id_city_find != 0)
			BEGIN
				INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point)  
					values(@ID_City, @Street, @Flat, @House, @Postcode, @Point);
				SET @id_User = @@IDENTITY;
				SELECT @checkFullName = count(*) FROM FullName 
					WHERE [name] = @name AND FullName.Surname = @sername and FullName.Patronymic = @Patronymic;
				if(@checkFullName = 0)
				BEGIN
					INSERT INTO FullName(name, Surname, Patronymic) values(@name, @sername, @Patronymic);	
					SET @id_fullName = @@IDENTITY;
					INSERT INTO [User](ID_User ,ID_Type, ID_FullName, [Login], [Password], number, mail)  
						values(@id_User, 2, @id_fullName, @login, @Password, @number, @mail);
				END;
				ELSE 
				BEGIN
					SELECT TOP(1) @ID_FullName = ID_FullName FROM FullName 
						WHERE [name] = @name AND FullName.Surname = @sername and FullName.Patronymic = @Patronymic;
					INSERT INTO [User](ID_User ,ID_Type, ID_FullName, [Login], [Password], number, mail)  
						values(@id_User, 2, @ID_FullName, @login, @Password, @number, @mail);
				END;
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'������ ID_City �� ����������';
		END;
		ELSE SET @mess = N'������������ � ����� ������� ��� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� �����
DROP PROCEDURE UpdatePassword;
GO
CREATE PROCEDURE UpdatePassword
	@login NVARCHAR(30),
	@Password NVARCHAR(30)
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @id_city_find int, @checkFullName int, @id_User int, @id_fullName int;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		if(@checkLogin != 0)
		BEGIN
			update [User] set [Password] = @Password where [Login] = @login;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'������������ � ����� ������� �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� ����
DROP PROCEDURE UpdateMail;
GO
CREATE PROCEDURE UpdateMail
	@login NVARCHAR(30),
	@mail NVARCHAR(100)
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @id_city_find int, @checkFullName int, @id_User int, @id_fullName int;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		if(@checkLogin != 0)
		BEGIN
			update [User] set [mail] = @mail where [Login] = @login;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'������������ � ����� ������� �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� ������ ��������
DROP PROCEDURE UpdateNumber;
GO
CREATE PROCEDURE UpdateNumber
	@login NVARCHAR(30),
	@number NVARCHAR(100)
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @id_city_find int, @checkFullName int, @id_User int, @id_fullName int;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		if(@checkLogin != 0)
		BEGIN
			update [User] set [number] = @number where [Login] = @login;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'������������ � ����� ������� �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� �����
DROP PROCEDURE DeleteUser;
GO
CREATE PROCEDURE DeleteUser
	@login NVARCHAR(30)
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @checkAdmin int, @Id_user int, @Id_users int;
		SET @Id_user = 0; SET @Id_users = 0;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		SELECT top(1) @Id_user = [User].ID_User from [User] WHERE [Login] = @login;
		if(@checkLogin != 0)
		BEGIN
			SELECT top(1) @checkAdmin = [User].ID_Type FROM [User] WHERE [Login] = @login;
			if(@checkAdmin = 2)
			BEGIN
				SELECT top(1) @Id_users = BookScore.ID_Users FROM BookScore WHERE ID_Users = @Id_user;
				if(@Id_users = 0)
				BEGIN
					SELECT top(1) @Id_users = [Order].ID_User FROM [Order] WHERE ID_User = @Id_user;
					if(@Id_users = 0)
					BEGIN
						delete [User] where [Login] = @login;
						select @Id_user;
						delete [Location] where ID_Location = @Id_user;
						SET @mess = N'��������� ��� ������';	
					END;
					ELSE SET @mess = N'� ������������ ��� �������� ������';	
				END;
				ELSE SET @mess = N'� ������������ ���� ������ ����';	
			END;
			else SET @mess = N'you have not permission';
		END;
		ELSE SET @mess = N'������������ � ����� ������� �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ������
DROP PROCEDURE CreateOrder;
GO
CREATE PROCEDURE CreateOrder
	@id_book int,
	@login NVARCHAR(30),
	@count int
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		DECLARE @checkLogin int, @checkAdmin int, @id_Order int, @Id_user int, @is_exist_book int;
		SET @Id_user = 0;
		SELECT @checkLogin = count(*) FROM [User] WHERE [Login] = @login;
		SELECT top(1) @Id_user = [User].ID_User from [User] WHERE [Login] = @login;
		if(@checkLogin != 0)
		BEGIN
			SELECT top(1) @is_exist_book = [Book].ID_Book from [Book] WHERE [ID_Book] = @id_book;
			if(@is_exist_book != 0)
			BEGIN
				if((SELECT top(1) [StatusOrder].ID_StatusOrder from [StatusOrder] WHERE [ID_StatusOrder] = 1) != 0)
				begin
					INSERT INTO [Order](ID_User, ID_StatusOrder, amount) values(@Id_user, 1, @count);
					SET @id_Order = @@IDENTITY;
					INSERT INTO [Books_Orders](ID_Books, ID_Orders, [Count]) values(@id_book, @id_Order, @count);
					SET @mess = N'��������� ��� ������';	
				end;
				else SET @mess = N'������� ����� �� ���������';
			END;
			else SET @mess = N'��������� ����� �� ����������';
		END;
		ELSE SET @mess = N'������������ � ����� ������� �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--���������� ����� � ������
DROP PROCEDURE AddBookToOrder;
GO
CREATE PROCEDURE AddBookToOrder
	@id_book int,
	@id_order int
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		if((SELECT top(1) [Order].ID_Order from [Order] WHERE [ID_Order] = @id_order) != 0)
		BEGIN
			if((SELECT top(1) COUNT(*) from [Books_Orders] WHERE [ID_Books] = @id_book AND [ID_Orders] = @id_order) != 0)
			BEGIN
				update [Books_Orders] set [Count] += 1 where [ID_Books] = @id_book AND [ID_Orders] = @id_order;
			END;
			else 
			BEGIN
				INSERT INTO [Books_Orders](ID_Books, ID_Orders, [Count]) values(@id_book, @id_Order, 1);
			END;
			update [Order] set [Order].[amount] += 1 where [Order].ID_Order = @id_order;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'������ ������ �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� �������
DROP PROCEDURE CreateBookScore;
GO
CREATE PROCEDURE CreateBookScore
	@id_book int,
	@id_user int,
	@rating int,
	@comment nvarchar(140)
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		if((SELECT COUNT(*) from [BookScore] WHERE [ID_Users] = @id_user AND [ID_Books] = @id_book) = 0)
		BEGIN
			if((SELECT top(1) COUNT(*) from [Book] WHERE [ID_Book] = @id_book) != 0)
			BEGIN
				if((SELECT top(1) COUNT(*) from [User] WHERE [ID_User] = @id_user) != 0)
				BEGIN
					INSERT INTO BookScore(ID_Books, ID_Users, rating, comment) values(@id_book, @id_user, @rating, @comment);
					SET @mess = N'��������� ��� ������';
				END;
				else SET @mess = N'������ ������������ �� ����������';
			END;
			else 
			SET @mess = N'����� ����� �� ����������';
		END;
		ELSE SET @mess = N'�� ��� ��������� ������� ���� �����';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ��������
DROP PROCEDURE CreateStore;
GO
CREATE PROCEDURE CreateStore
	@name NVARCHAR(30),
	@ID_City int,
	@Street nvarchar(50),
	@Flat int,
	@House int,
	@Postcode int,
	@latitude FLOAT,
	@longitude FLOAT
AS
BEGIN
	DECLARE @mess NVARCHAR(200), @Point geography;
	SET @Point = geography::Point(@latitude, @longitude, 4326);
	SET @mess='';
	BEGIN TRY
		DECLARE @id_Store int;
		if((SELECT top(1) ID_City from City where ID_City = @ID_City) != 0)
		BEGIN
			INSERT INTO [Location](ID_City, Street, Flat, House, Postcode, Point)  
				values(@ID_City, @Street, @Flat, @House, @Postcode, @Point);
			SET @id_Store = @@IDENTITY;
			INSERT INTO Book_Store(ID_Book_Store, Name) values(@id_Store, @name);
			INSERT INTO Library(ID_Library, Amount) values(@id_Store, 0);
			SET @mess = N'��������� ��� ������';
		END;
		else SET @mess = N'������ ID_City �� ����������';
		END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ��������
DROP PROCEDURE DeleteStore;
GO
CREATE PROCEDURE DeleteStore
	@ID_Store int
AS
BEGIN
	DECLARE @mess NVARCHAR(200), @Point geography;
	SET @mess='';
	BEGIN TRY
		if((SELECT COUNT(*) from Libraries_Books where ID_Libraries = @ID_Store) = 0)
		BEGIN
			delete from Library where ID_Library = @ID_Store;
			delete from Book_Store where ID_Book_Store = @ID_Store;
			delete from Location where ID_Location = @ID_Store;
			SET @mess = N'��������� ��� ������';
		END;
		else SET @mess = N'������ ������� �� ������ �������';
		END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ������� ������������
DROP PROCEDURE GetMyOrders;
GO
CREATE PROCEDURE GetMyOrders
	@id_user int
AS
BEGIN
	DECLARE @mess NVARCHAR(200);
	SET @mess='';
	BEGIN TRY
		if((SELECT COUNT(*) from [User] WHERE [ID_User] = @id_user) != 0)
		BEGIN
			select [Book].[ID_Book], [Book].[Name], [Books_Orders].[Count] from [Order] 
				inner join [Books_Orders] on [Order].ID_Order = [Books_Orders].ID_Orders
				inner join [Book] on [Books_Orders].ID_Books = [Book].ID_Book 
				where ID_User = @id_user; 
		END;
		ELSE SET @mess = N'������ ������������ �� ����������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ���� ����
DROP PROCEDURE GetAllBook;
GO
CREATE PROCEDURE GetAllBook
AS
BEGIN
	select * from [Book];
END
GO
---------------------------------------------------------------------------
--�������� ���� ���������
DROP PROCEDURE GetAllStores;
GO
CREATE PROCEDURE GetAllStores
AS
BEGIN
	select Book_Store.ID_Book_Store, Book_Store.Name, City.Name, Location.Street, Location.House, Location.Flat from [Book_Store]
		inner join [Location] on [Book_Store].ID_Book_Store = [Location].ID_Location
		inner join [City] on [Location].ID_City = [City].ID_City;
END
GO
---------------------------------------------------------------------------
--�������� ���� �������
DROP PROCEDURE GetAllOrders;
GO
CREATE PROCEDURE GetAllOrders
AS
BEGIN
	select * from [Order];
END
GO
---------------------------------------------------------------------------
--�������� ���� ���������
DROP PROCEDURE GetAllPublishOffice;
GO
CREATE PROCEDURE GetAllPublishOffice
AS
BEGIN
	select ID_Publish_Office, Publish_Office.Name, City.Name, Location.Street, Location.House, Location.Flat from [Publish_Office] 
		inner join [Location] on [Publish_Office].ID_Publish_Office = Location.ID_Location
		inner join [City] on [City].ID_City = [Location].ID_City;
END
GO
---------------------------------------------------------------------------
--�������� ������
DROP PROCEDURE CreateAuthor;
GO
CREATE PROCEDURE CreateAuthor
	@name NVARCHAR(30),
	@sername NVARCHAR(30),
	@Patronymic NVARCHAR(30)
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200), @checkFullName int;
		SELECT @checkFullName = count(*) FROM FullName 
			WHERE [name] = @name AND FullName.Surname = @sername and FullName.Patronymic = @Patronymic;
		if(@checkFullName = 0)
		BEGIN
			INSERT INTO FullName(name, Surname, Patronymic) values(@name, @sername, @Patronymic);	
			INSERT INTO Author(ID_FullName) values(@@IDENTITY);	
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'����� � ������ ���������� ��� ����������';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ������
DROP PROCEDURE DeleteAuthor;
GO
CREATE PROCEDURE DeleteAuthor
	@id_author int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Authors_Books where id_Author = @id_author) = 0)
		BEGIN
			delete from Author where ID_Author = @id_author;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'� ������ �������� �����';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� �������
DROP PROCEDURE GetAllAuthors;
GO
CREATE PROCEDURE GetAllAuthors
AS
BEGIN
	BEGIN
		Select Author.ID_Author, FullName.Surname, FullName.Name, FullName.Patronymic from Author
			inner join FullName on Author.ID_FullName = FullName.ID_FullName;
	END;
END
GO
---------------------------------------------------------------------------
--���������� ������ �����
DROP PROCEDURE AddAuthorToBook;
GO
CREATE PROCEDURE AddAuthorToBook
	@id_author int,
	@id_book int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Author where id_Author = @id_author) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				INSERT INTO Authors_Books(ID_Author, ID_Books) values(@id_author, @id_book);
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'������ ������ ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ������ �����
DROP PROCEDURE DeleteBooksAuthor;
GO
CREATE PROCEDURE DeleteBooksAuthor
	@id_author int,
	@id_book int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Author where id_Author = @id_author) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				delete from [Authors_Books] where id_Author = @id_author AND ID_Books = @id_book;
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'������ ������ ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� ������� ������
DROP PROCEDURE ChangeStatusOrder;
GO
CREATE PROCEDURE ChangeStatusOrder
	@id_Order int,
	@id_Status int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from [Order] where ID_Order = @id_Order) != 0)
		BEGIN
			if((Select COUNT(*) from StatusOrder where ID_StatusOrder = @id_Status) != 0)
			BEGIN
				Update [Order] SET ID_StatusOrder = @id_Status where ID_Order = @id_Order;
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'������ ������� ���';
			END;
		ELSE SET @mess = N'������ ������ ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� �������
DROP PROCEDURE CreatePicture;
GO
CREATE PROCEDURE CreatePicture
	@url nvarchar(MAX)
AS
	DECLARE @mess nvarchar(50);
	BEGIN TRY
		INSERT INTO Envelope(Url) values(@url);
		SET @mess = N'��������� ��� ������';
	END TRY
	BEGIN CATCH
		SET @mess = N'������ �������!';
	END CATCH;
	select @mess;
GO
---------------------------------------------------------------------------
--���������� ������� � �����
DROP PROCEDURE AddPictureToBook;
GO
CREATE PROCEDURE AddPictureToBook
	@id_envelope int,
	@id_book int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Envelope where ID_Envelope = @id_envelope) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				INSERT INTO Envelopes_Books(ID_Envelope, ID_Books) values(@id_envelope, @id_book);
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'����� ������� ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ������� � �����
DROP PROCEDURE DeleteEnvelopsAuthor;
GO
CREATE PROCEDURE DeleteEnvelopsAuthor
	@id_envelope int,
	@id_book int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Envelope where id_envelope = @id_envelope) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				delete from [Envelopes_Books] where ID_Envelope = @id_envelope AND ID_Books = @id_book;
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'����� ������� ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� �������
DROP PROCEDURE DeletePictures;
GO
CREATE PROCEDURE DeletePictures
	@id_envelope int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from Envelopes_Books where ID_Envelope = @id_envelope) = 0)
		BEGIN
			delete from Envelope where ID_Envelope = @id_envelope;
			SET @mess = N'��������� ��� ������';
		END;
		ELSE SET @mess = N'������� ������������ � ������';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ���� ��������(�������)
DROP PROCEDURE GetAllPictures;
GO
CREATE PROCEDURE GetAllPictures
AS
BEGIN
	select * from Envelope;
END
GO
---------------------------------------------------------------------------
--�������� �����
DROP PROCEDURE CreateBook;
GO
CREATE PROCEDURE CreateBook
	@name nvarchar(50),
	@Description nvarchar(500),
	@Price int,
	@ID_Publication_Type int,
	@ID_Publishing_Office int,
	@Size int,
	@ID_Format int,
	@Weight int,
	@Age_Limit int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((SELECT count(*) FROM [Format] WHERE ID_Format = @ID_Format) != 0)
		BEGIN
			if((SELECT count(*) FROM [Publication_Type] WHERE ID_Publication_Type = @ID_Publication_Type) != 0)
			BEGIN
				if((SELECT count(*) FROM [Publish_Office] WHERE ID_Publish_Office = @ID_Publishing_Office) != 0)
				BEGIN
					INSERT INTO Book(name, Description, Price, ID_Publication_Type, ID_Publishing_Office, size, ID_Format, Weight, Age_Limit) 
						values(@name, @Description, @price, @ID_Publication_Type, @ID_Publishing_Office, @Size, @ID_Format, @Weight, @Age_Limit);	
					SET @mess = N'��������� ��� ������';
				END;
				ELSE SET @mess = N'�������� id ��������';
			END;
			ELSE SET @mess = N'�������� id ���� ����������';
		END;
		ELSE SET @mess = N'�������� id �������';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--���������� ����� � ����������
DROP PROCEDURE AddBookToLibrary;
GO
CREATE PROCEDURE AddBookToLibrary
	@id_lib int,
	@id_book int,
	@amount int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200);
		if((Select COUNT(*) from [Library] where ID_Library = @id_lib) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				UPDATE Library SET Amount+=@amount where ID_Library = @id_lib;
				if((Select COUNT(*) from Libraries_Books where ID_Books = @id_book AND ID_Libraries = @id_lib) != 0)
				BEGIN
					UPDATE Libraries_Books SET Amount+=@amount where ID_Books = @id_book AND ID_Libraries = @id_lib;
				END;
				ELSE BEGIN
					INSERT INTO Libraries_Books(ID_Libraries, ID_Books, Amount) values(@id_lib, @id_book, @amount);
				END;
				SET @mess = N'��������� ��� ������';
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'����� ���������� ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--�������� ����� �� ����������
DROP PROCEDURE DeleteLibrariesBook;
GO
CREATE PROCEDURE DeleteLibrariesBook
	@id_lib int,
	@id_book int,
	@count int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200), @countBook int;
		if((Select COUNT(*) from [Library] where ID_Library = @id_lib) != 0)
		BEGIN
			if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
			BEGIN
				if((Select COUNT(*) from Book where ID_Book = @id_book) != 0)
				BEGIN
					Select @countBook = Amount from Libraries_Books where ID_Libraries = @id_lib AND ID_Books = @id_book
					if(@countBook >= @count)
					BEGIN
						UPDATE Library SET Amount-= @count
							where ID_Library = @id_lib;
						if(@countBook = @count)
						BEGIN
							delete from [Libraries_Books] where ID_Libraries = @id_lib AND ID_Books = @id_book;
						END;
						ELSE BEGIN
							UPDATE [Libraries_Books] SET Amount-= @count
								where ID_Books = @id_book AND ID_Libraries = @id_lib;
						END;
						SET @mess = N'��������� ��� ������';
					END;
					ELSE SET  @mess = N'������ ������� ���� ������ ��� ��������� � ��������';
				END;
			END;
			else SET @mess = N'����� ����� ���';
			END;
		ELSE SET @mess = N'����� ���������� ���';
	END;
	select @mess;
END
GO
---------------------------------------------------------------------------
--��������� ���� ���� �� ����������
DROP PROCEDURE GetAllBookInStorage;
GO
CREATE PROCEDURE GetAllBookInStorage
	@id_lib int
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200), @countBook int;
		if((Select COUNT(*) from [Library] where ID_Library = @id_lib) != 0)
		BEGIN
			Select Book_Store.ID_Book_Store, Book_Store.Name, Amount, Book.*, City.Name as City, Location.Street, Location.House, Location.Flat from Libraries_Books
				inner join Book_Store on ID_Book_Store = ID_Libraries
				inner join Location on ID_Location = ID_Book_Store
				inner join Book on ID_Book = ID_Books
				inner join City on City.ID_City = Location.ID_City where Book_Store.ID_Book_Store = @id_lib;
		END;
		ELSE BEGIN
			SET @mess = N'����� ���������� ���';
			select @mess;
			END;
	END;
END
GO
---------------------------------------------------------------------------
--��������� ���� ���� �� ����������
DROP PROCEDURE GetAllUsers;
GO
CREATE PROCEDURE GetAllUsers
AS
BEGIN
	select * from [User]
		inner join [Location] on [User].ID_User = [Location].ID_Location;
END
GO
---------------------------------------------------------------------------
--��������� ���� �����
DROP PROCEDURE GetAllPublishType;
GO
CREATE PROCEDURE GetAllPublishType
AS
BEGIN
	select * from [Publication_Type];
END
GO
---------------------------------------------------------------------------
--��������� FIO
DROP PROCEDURE GetAllFullName;
GO
CREATE PROCEDURE GetAllFullName
AS
BEGIN
	select * from [FullName];
END
GO
---------------------------------------------------------------------------
--��������� Cities
DROP PROCEDURE GetAllCities;
GO
CREATE PROCEDURE GetAllCities
AS
BEGIN
	select * from [City];
END
GO
---------------------------------------------------------------------------
--��������� Formats
DROP PROCEDURE GetAllFormats;
GO
CREATE PROCEDURE GetAllFormats
AS
BEGIN
	select * from [Format];
END
GO
---------------------------------------------------------------------------
--��������� Books_Orders
DROP PROCEDURE GetAllBooks_Orders;
GO
CREATE PROCEDURE GetAllBooks_Orders
AS
BEGIN
	select * from [Books_Orders];
END
GO
---------------------------------------------------------------------------
--��������� ���� ������� ������������
DROP PROCEDURE GetAllUserOrders;
GO
CREATE PROCEDURE GetAllUserOrders
	@login nvarchar(50)
AS
BEGIN
	BEGIN
		DECLARE @mess NVARCHAR(200), @countBook int;
		if((Select COUNT(*) from [User] where [User].[Login] = @login) != 0)
		BEGIN
			Select ID_Order, [login], [Count], Book.Name, Price from [User]
				inner join [Order] on [User].ID_User = [Order].ID_User
				inner join Books_Orders on Books_Orders.ID_Orders = [Order].ID_Order
				inner join Book on Book.ID_Book = [Books_Orders].ID_Books;
		END;
		ELSE BEGIN
			SET @mess = N'������ ������������ ���';
			select @mess;
			END;
	END;
END
GO
---------------------------------------------------------------------------
-- ����� ���������� ��������
DROP PROCEDURE FindNearestStoreWithBook;
GO
CREATE PROCEDURE FindNearestStoreWithBook
	@login NVARCHAR(30),
	@Book NVARCHAR(30)
AS
BEGIN
	BEGIN TRY
		DECLARE @check INT;
		SELECT @check = ID_User FROM [User] WHERE Login = @login;
		IF(@check > 0)
		BEGIN
			DECLARE @userPoint geography;
			SELECT @userPoint  = Point FROM [Location] WHERE ID_Location = @check;
			select TOP 3 @userPoint.STDistance(Point) as distance, 
			Book_Store.Name as Store, City.Name as City, Location.Street, Location.House, Location.Flat 
				from [Location] 
					inner join Book_Store on Book_Store.ID_Book_Store = Location.ID_Location
					inner join City on Location.ID_City = City.ID_City
					inner join Libraries_Books on Book_Store.ID_Book_Store=Libraries_Books.ID_Libraries
					inner join Book on Book.ID_Book = Libraries_Books.ID_Books
						where Book.Name = @Book
						ORDER BY distance;
		END;
		ELSE SELECT N'������ ������� �� ����������!';
	END TRY
	BEGIN CATCH
		SELECT N'������ �������!';
	END CATCH;
END
GO