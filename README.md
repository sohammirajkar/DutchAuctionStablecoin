
# Dutch Auction Stablecoin

This project implements a decentralized exchange (DEX) for a stablecoin that uses Dutch auctions. The backend is built with Scala and the smart contracts are written in Vyper. The project also uses Slick for database interaction with PostgreSQL.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Building the Project](#building-the-project)
4. [Running the Project](#running-the-project)
5. [Testing](#testing)
6. [Project Structure](#project-structure)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Java JDK** (version 8 or higher)
- **Scala** (version 2.13.12)
- **SBT** (Scala Build Tool)
- **PostgreSQL** (with DBngin and TablePlus for ease of use)
- **Vyper** (for compiling smart contracts)
- **Foundry** (for compiling and testing smart contracts)
- **Git** (for version control)

## Setup

### Step 1: Clone the Repository

```sh
git clone https://github.com/sohammirajkar/DutchAuctionStablecoin.git
cd DutchAuctionStablecoin
```

### Step 2: Set Up PostgreSQL Database

1. **Install and Configure DBngin**:
   - Download DBngin from [DBngin](https://dbngin.com/) and install it.
   - Create a new PostgreSQL server in DBngin with the default port `5432`.

2. **Set Up PostgreSQL Using TablePlus**:
   - Download TablePlus from [TablePlus](https://tableplus.com/) and install it.
   - Connect to your PostgreSQL server using TablePlus with the following details:
     - Host: `localhost`
     - Port: `5432`
     - User: `postgres`
     - Password: (set during DBngin setup)
     - Database: `postgres`
   - Run the following SQL commands to create a new database and user:

```sql
CREATE DATABASE mydatabase;
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;
```

### Step 3: Configure the Project

1. **application.conf**:
   - Create a configuration file `src/main/resources/application.conf` with the following content:

```hocon
mydb = {
  url = "jdbc:postgresql://localhost:5432/mydatabase"
  driver = "org.postgresql.Driver"
  user = "myuser"
  password = "mypassword"
  connectionPool = "HikariCP"
  keepAliveConnection = true
}
```

### Step 4: Compile and Deploy Vyper Contracts

1. **Install Foundry**:
   - Follow the [Foundry installation guide](https://book.getfoundry.sh/getting-started/installation) to install Foundry.

2. **Compile and Deploy Contracts**:
   - Navigate to the `contracts` directory and compile the Vyper contracts using Foundry:

```sh
forge build
```

3. **Deploy Contracts**:
   - Use Foundry or another deployment tool to deploy the Vyper contracts to a test network.

## Building the Project

1. **Ensure Dependencies and Configuration**:
   - Verify that your `build.sbt` file includes the necessary dependencies and settings:

```sbt
import Dependencies._

ThisBuild / scalaVersion := "2.13.12"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "com.example"
ThisBuild / organizationName := "example"

lazy val root = (project in file("."))
  .settings(
    name := "DutchAuctionStablecoin",
    version := "0.1",
    libraryDependencies ++= Seq(
      "com.typesafe.slick" %% "slick" % "3.3.3",
      "org.postgresql" % "postgresql" % "42.2.20",
      "com.typesafe.slick" %% "slick-hikaricp" % "3.3.3",
      "org.scalatest" %% "scalatest" % "3.2.9" % Test,
      "org.web3j" % "core" % "4.8.7"
    ),
    mainClass in Compile := Some("MainApp")
  )
```

2. **Clean and Compile the Project**:
   - Open a terminal, navigate to the project directory, and run:

```sh
sbt clean compile
```

## Running the Project

1. **Run the Main Application**:
   - Initialize the database schema and start the application:

```sh
sbt run
```

2. **Expected Output**:
   - You should see a message indicating that the database schema has been successfully created.

## Testing

1. **Write Unit Tests**:
   - Create unit tests for your Scala code using ScalaTest. An example test file could be `src/test/scala/AuctionManagerSpec.scala`:

```scala
// File: src/test/scala/AuctionManagerSpec.scala

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import slick.jdbc.PostgresProfile.api._
import scala.concurrent.Await
import scala.concurrent.duration._

class AuctionManagerSpec extends AnyFlatSpec with Matchers {
  "AuctionManager" should "correctly start an auction" in {
    val auction = Auction(1, Instant.now, Instant.now.plusSeconds(3600), BigDecimal(100), BigDecimal(50))
    val future = AuctionManager.startAuction(auction)
    val result = Await.result(future, 10.seconds)
    result should be (1)
  }

  it should "correctly place a bid" in {
    val future = AuctionManager.placeBid(1, "0xBidderAddress", BigDecimal(75))
    val result = Await.result(future, 10.seconds)
    result should be (1)
  }

  it should "correctly calculate current price" in {
    val auction = Auction(1, Instant.now.minusSeconds(1800), Instant.now.plusSeconds(1800), BigDecimal(100), BigDecimal(50))
    val price = AuctionManager.getCurrentPrice(auction)
    price should be (BigDecimal(75))
  }
}
```

2. **Run the Tests**:
   - Execute the tests using SBT:

```sh
sbt test
```

## Project Structure

```
project-root/
├── build.sbt
├── src/
│   └── main/
│       └── scala/
│           ├── MainApp.scala
│           └── DatabaseSchema.scala
│   └── main/
│       └── resources/
│           └── application.conf
├── src/
│   └── test/
│       └── scala/
│           └── AuctionManagerSpec.scala
```
