-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Aug 07, 2025 at 05:10 AM
-- Server version: 10.11.10-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u621169360_eduapp`
--

-- --------------------------------------------------------

--
-- Table structure for table `Assignments`
--

CREATE TABLE `Assignments` (
  `AssignmentID` int(11) NOT NULL,
  `SubjectID` int(11) DEFAULT NULL,
  `Title` varchar(150) NOT NULL,
  `Description` text DEFAULT NULL,
  `DueDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `CareerCounselling`
--

CREATE TABLE `CareerCounselling` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(120) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Courses`
--

CREATE TABLE `Courses` (
  `CourseID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` text DEFAULT NULL,
  `ImageURL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Courses`
--

INSERT INTO `Courses` (`CourseID`, `Name`, `Description`, `ImageURL`) VALUES
(1, 'Class 12', 'Comprehensive course for Class 12 students covering all major subjects.', 'https://yourdomain.com/assets/images/class12.png'),
(2, 'NEET', 'NEET preparation course with detailed study materials and practice tests.', 'https://yourdomain.com/assets/images/neet.png');

-- --------------------------------------------------------

--
-- Table structure for table `PracticeTests`
--

CREATE TABLE `PracticeTests` (
  `TestID` int(11) NOT NULL,
  `SubjectID` int(11) DEFAULT NULL,
  `Title` varchar(150) NOT NULL,
  `Description` text DEFAULT NULL,
  `TotalQuestions` int(11) DEFAULT NULL,
  `Duration` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `StoreItems`
--

CREATE TABLE `StoreItems` (
  `ItemID` int(11) NOT NULL,
  `Title` varchar(150) NOT NULL,
  `Subtitle` varchar(255) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `OriginalPrice` decimal(10,2) DEFAULT NULL,
  `ImageURL` varchar(255) DEFAULT NULL,
  `Type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `StudyMaterials`
--

CREATE TABLE `StudyMaterials` (
  `MaterialID` int(11) NOT NULL,
  `TopicID` int(11) DEFAULT NULL,
  `Title` varchar(150) NOT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `URL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Subjects`
--

CREATE TABLE `Subjects` (
  `SubjectID` int(11) NOT NULL,
  `CourseID` int(11) DEFAULT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` text DEFAULT NULL,
  `Icon` varchar(100) DEFAULT NULL,
  `Color` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Subjects`
--

INSERT INTO `Subjects` (`SubjectID`, `CourseID`, `Name`, `Description`, `Icon`, `Color`) VALUES
(1, 1, 'Mathematicss', 'Mathematics for Class 12', 'calculate', '#8B5CF6'),
(2, 1, 'Physics', 'Physics for Class 12', 'science', '#3B82F6'),
(3, 1, 'Chemistry', 'Chemistry for Class 12', 'flag', '#F59E0B'),
(4, 1, 'Biology', 'Biology for Class 12', 'biotech', '#14B8A6'),
(5, 2, 'Botany', 'Botany for NEET', 'eco', '#22D3EE'),
(6, 2, 'Zoology', 'Zoology for NEET', 'pets', '#F472B6'),
(7, 2, 'Physics', 'Physics for NEET', 'science', '#3B82F6'),
(8, 2, 'Chemistry', 'Chemistry for NEET', 'flag', '#F59E0B');

-- --------------------------------------------------------

--
-- Table structure for table `Topics`
--

CREATE TABLE `Topics` (
  `TopicID` int(11) NOT NULL,
  `SubjectID` int(11) DEFAULT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `UserID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Userphone` varchar(100) NOT NULL,
  `address` text DEFAULT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `UserType` text DEFAULT NULL,
  `partner_type` text DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `fcm_token` text DEFAULT NULL,
  `profile_photo` text DEFAULT NULL,
  `is_active` varchar(255) DEFAULT 'No',
  `is_packing` text DEFAULT NULL,
  `Phone` varchar(20) NOT NULL,
  `Courses` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`UserID`, `Name`, `Userphone`, `address`, `Password`, `Email`, `UserType`, `partner_type`, `CreatedAt`, `fcm_token`, `profile_photo`, `is_active`, `is_packing`, `Phone`, `Courses`) VALUES
(127, 'Rajat Pradhan', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'rajat@gmail.com', 'Customer', NULL, '2025-07-25 11:08:58', NULL, NULL, 'No', NULL, '', ''),
(162, '123', '', NULL, 'd79c8788088c2193f0244d8f1f36d2db', '7777', 'Customer', NULL, '2025-07-26 09:14:39', NULL, NULL, 'No', NULL, '', ''),
(163, 'paban', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'paban@gmail.com', 'Customer', NULL, '2025-07-26 09:15:28', NULL, NULL, 'No', NULL, '', ''),
(164, 'paban', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'charuxaikia1991@gmail.com', 'Customer', NULL, '2025-07-29 12:47:43', NULL, NULL, 'No', NULL, '', ''),
(165, 'binoy', '', NULL, 'f8b79d364a1575694c07606e34654874', 'binoysahariah3@gmail.com', 'Customer', NULL, '2025-07-31 11:25:09', NULL, NULL, 'No', NULL, '', ''),
(166, 'Bhaskar Jyoti Das', '', NULL, '3311a4d93ccd690204118848e7f0c48d', 'bjsrk007@gmail.com', 'Customer', NULL, '2025-07-31 11:27:03', NULL, NULL, 'No', NULL, '', ''),
(167, 'hirak', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'hirak@gmail.com', 'Customer', NULL, '2025-07-31 11:59:17', NULL, NULL, 'No', NULL, '', ''),
(168, 'awefadsfas', '', NULL, '25d55ad283aa400af464c76d713c07ad', 'asdfas@gmail.com', 'Customer', NULL, '2025-08-01 04:51:13', NULL, NULL, 'No', NULL, '', ''),
(169, 'asdfasd', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'werqqw@mail.com', 'Customer', NULL, '2025-08-01 05:57:58', NULL, NULL, 'No', NULL, '', ''),
(170, 'wecxvz', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'adewa@mail.com', 'Customer', NULL, '2025-08-01 05:59:43', NULL, NULL, 'No', NULL, '', ''),
(171, 'sadf awfxvas', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'aserafwfrsa@mail.com', 'Customer', NULL, '2025-08-01 08:49:34', NULL, NULL, 'No', NULL, '', ''),
(172, 'opsn cndodp', '', NULL, '1619b32037a2edf898e1ed85f3d1c869', 'pdonvnd@mseij.com', 'Customer', NULL, '2025-08-01 11:52:31', NULL, NULL, 'No', NULL, '', ''),
(174, 'Charu Saikia', '', NULL, 'e10adc3949ba59abbe56e057f20f883e', 'zzubizubi@gmail.com', 'Customer', NULL, '2025-08-02 07:11:06', NULL, NULL, 'No', NULL, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `Videos`
--

CREATE TABLE `Videos` (
  `VideoID` int(11) NOT NULL,
  `TopicID` int(11) DEFAULT NULL,
  `Title` varchar(150) NOT NULL,
  `URL` varchar(255) DEFAULT NULL,
  `Thumbnail` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Assignments`
--
ALTER TABLE `Assignments`
  ADD PRIMARY KEY (`AssignmentID`),
  ADD KEY `SubjectID` (`SubjectID`);

--
-- Indexes for table `CareerCounselling`
--
ALTER TABLE `CareerCounselling`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Courses`
--
ALTER TABLE `Courses`
  ADD PRIMARY KEY (`CourseID`);

--
-- Indexes for table `PracticeTests`
--
ALTER TABLE `PracticeTests`
  ADD PRIMARY KEY (`TestID`),
  ADD KEY `SubjectID` (`SubjectID`);

--
-- Indexes for table `StoreItems`
--
ALTER TABLE `StoreItems`
  ADD PRIMARY KEY (`ItemID`);

--
-- Indexes for table `StudyMaterials`
--
ALTER TABLE `StudyMaterials`
  ADD PRIMARY KEY (`MaterialID`),
  ADD KEY `TopicID` (`TopicID`);

--
-- Indexes for table `Subjects`
--
ALTER TABLE `Subjects`
  ADD PRIMARY KEY (`SubjectID`),
  ADD KEY `CourseID` (`CourseID`);

--
-- Indexes for table `Topics`
--
ALTER TABLE `Topics`
  ADD PRIMARY KEY (`TopicID`),
  ADD KEY `SubjectID` (`SubjectID`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `Videos`
--
ALTER TABLE `Videos`
  ADD PRIMARY KEY (`VideoID`),
  ADD KEY `TopicID` (`TopicID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Assignments`
--
ALTER TABLE `Assignments`
  MODIFY `AssignmentID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `CareerCounselling`
--
ALTER TABLE `CareerCounselling`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Courses`
--
ALTER TABLE `Courses`
  MODIFY `CourseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `PracticeTests`
--
ALTER TABLE `PracticeTests`
  MODIFY `TestID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `StoreItems`
--
ALTER TABLE `StoreItems`
  MODIFY `ItemID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `StudyMaterials`
--
ALTER TABLE `StudyMaterials`
  MODIFY `MaterialID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Subjects`
--
ALTER TABLE `Subjects`
  MODIFY `SubjectID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `Topics`
--
ALTER TABLE `Topics`
  MODIFY `TopicID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;

--
-- AUTO_INCREMENT for table `Videos`
--
ALTER TABLE `Videos`
  MODIFY `VideoID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Assignments`
--
ALTER TABLE `Assignments`
  ADD CONSTRAINT `Assignments_ibfk_1` FOREIGN KEY (`SubjectID`) REFERENCES `Subjects` (`SubjectID`);

--
-- Constraints for table `PracticeTests`
--
ALTER TABLE `PracticeTests`
  ADD CONSTRAINT `PracticeTests_ibfk_1` FOREIGN KEY (`SubjectID`) REFERENCES `Subjects` (`SubjectID`);

--
-- Constraints for table `StudyMaterials`
--
ALTER TABLE `StudyMaterials`
  ADD CONSTRAINT `StudyMaterials_ibfk_1` FOREIGN KEY (`TopicID`) REFERENCES `Topics` (`TopicID`);

--
-- Constraints for table `Subjects`
--
ALTER TABLE `Subjects`
  ADD CONSTRAINT `Subjects_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `Courses` (`CourseID`);

--
-- Constraints for table `Topics`
--
ALTER TABLE `Topics`
  ADD CONSTRAINT `Topics_ibfk_1` FOREIGN KEY (`SubjectID`) REFERENCES `Subjects` (`SubjectID`);

--
-- Constraints for table `Videos`
--
ALTER TABLE `Videos`
  ADD CONSTRAINT `Videos_ibfk_1` FOREIGN KEY (`TopicID`) REFERENCES `Topics` (`TopicID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
