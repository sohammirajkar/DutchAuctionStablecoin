import Dependencies._

ThisBuild / scalaVersion := "2.13.12"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "com.example"
ThisBuild / organizationName := "example"

lazy val root = (project in file("."))
  .settings(
    name := "DutchAuctionStablecoin",
    version := "0.1",
    scalaVersion := "2.13.12", // Make sure this matches the ThisBuild setting
    libraryDependencies ++= Seq(
      "com.typesafe.slick" %% "slick" % "3.3.3",
      "org.postgresql" % "postgresql" % "42.2.20",
      "com.typesafe.slick" %% "slick-hikaricp" % "3.3.3",
      "org.scalatest" %% "scalatest" % "3.2.9" % Test,
      "org.web3j" % "core" % "4.8.7"
    ),
    mainClass in Compile := Some("MainApp")
  )
