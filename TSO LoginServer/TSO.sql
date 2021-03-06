/****** Object:  ForeignKey [FK_Accounts_Character1]    Script Date: 05/06/2012 17:54:20 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character1]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts] DROP CONSTRAINT [FK_Accounts_Character1]
GO
/****** Object:  ForeignKey [FK_Accounts_Character2]    Script Date: 05/06/2012 17:54:20 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character2]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts] DROP CONSTRAINT [FK_Accounts_Character2]
GO
/****** Object:  ForeignKey [FK_Accounts_Character3]    Script Date: 05/06/2012 17:54:20 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character3]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts] DROP CONSTRAINT [FK_Accounts_Character3]
GO
/****** Object:  Table [dbo].[Accounts]    Script Date: 05/06/2012 17:54:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Accounts]') AND type in (N'U'))
DROP TABLE [dbo].[Accounts]
GO
/****** Object:  Table [dbo].[FTPAccounts]    Script Date: 05/06/2012 17:54:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FTPAccounts]') AND type in (N'U'))
DROP TABLE [dbo].[FTPAccounts]
GO
/****** Object:  Table [dbo].[Characters]    Script Date: 05/06/2012 17:54:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Characters]') AND type in (N'U'))
DROP TABLE [dbo].[Characters]
GO
/****** Object:  Role [Mats]    Script Date: 05/06/2012 17:54:20 ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Mats')
BEGIN
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Mats' AND type = 'R')
CREATE ROLE [Mats]

END
GO
/****** Object:  Table [dbo].[Characters]    Script Date: 05/06/2012 17:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Characters]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Characters](
	[CharacterID] [int] IDENTITY(1,1) NOT NULL,
	[GUID] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[LastCached] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[Name] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[Sex] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[City] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
 CONSTRAINT [PK_Character] PRIMARY KEY CLUSTERED 
(
	[CharacterID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
END
GO
/****** Object:  Table [dbo].[FTPAccounts]    Script Date: 05/06/2012 17:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FTPAccounts]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FTPAccounts](
	[AccountName] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[Password] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL
)
END
GO
INSERT [dbo].[FTPAccounts] ([AccountName], [Password]) VALUES (N'TSOClient', N'test')
/****** Object:  Table [dbo].[Accounts]    Script Date: 05/06/2012 17:54:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Accounts]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Accounts](
	[AccountID] [int] IDENTITY(1,1) NOT NULL,
	[AccountName] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[Password] [nvarchar](50) COLLATE Danish_Norwegian_CI_AS NULL,
	[NumCharacters] [int] NULL,
	[Character1] [int] NULL,
	[Character2] [int] NULL,
	[Character3] [int] NULL,
 CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
END
GO
SET IDENTITY_INSERT [dbo].[Accounts] ON
INSERT [dbo].[Accounts] ([AccountID], [AccountName], [Password], [NumCharacters], [Character1], [Character2], [Character3]) VALUES (1, N'Afr0', N'prins123', 0, NULL, NULL, NULL)
INSERT [dbo].[Accounts] ([AccountID], [AccountName], [Password], [NumCharacters], [Character1], [Character2], [Character3]) VALUES (2, N'Nico', N'pass', 0, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Accounts] OFF
/****** Object:  ForeignKey [FK_Accounts_Character1]    Script Date: 05/06/2012 17:54:20 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character1]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [FK_Accounts_Character1] FOREIGN KEY([Character1])
REFERENCES [dbo].[Characters] ([CharacterID])
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_Character1]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Accounts', N'CONSTRAINT',N'FK_Accounts_Character1'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'References the first character for the account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Accounts', @level2type=N'CONSTRAINT',@level2name=N'FK_Accounts_Character1'
GO
/****** Object:  ForeignKey [FK_Accounts_Character2]    Script Date: 05/06/2012 17:54:20 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character2]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [FK_Accounts_Character2] FOREIGN KEY([Character2])
REFERENCES [dbo].[Characters] ([CharacterID])
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_Character2]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Accounts', N'CONSTRAINT',N'FK_Accounts_Character2'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'References the second character for the account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Accounts', @level2type=N'CONSTRAINT',@level2name=N'FK_Accounts_Character2'
GO
/****** Object:  ForeignKey [FK_Accounts_Character3]    Script Date: 05/06/2012 17:54:20 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Accounts_Character3]') AND parent_object_id = OBJECT_ID(N'[dbo].[Accounts]'))
ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [FK_Accounts_Character3] FOREIGN KEY([Character3])
REFERENCES [dbo].[Characters] ([CharacterID])
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_Character3]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Accounts', N'CONSTRAINT',N'FK_Accounts_Character3'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'References the third character for the account.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Accounts', @level2type=N'CONSTRAINT',@level2name=N'FK_Accounts_Character3'
GO
