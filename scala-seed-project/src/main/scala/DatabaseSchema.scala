// File: src/main/scala/DatabaseSchema.scala

import slick.jdbc.PostgresProfile.api._
import scala.concurrent.Await
import scala.concurrent.duration._
import scala.util.{Failure, Success}

object DatabaseSchema {
  val db = Database.forConfig("mydb")

  val auctions = TableQuery[Auctions]
  val bids = TableQuery[Bids]

  def createSchema(): Unit = {
    val setup = DBIO.seq(
      (auctions.schema ++ bids.schema).createIfNotExists
    )
    val setupFuture = db.run(setup)
    Await.result(
      setupFuture,
      10.seconds
    ) // Wait for the schema creation to complete
    setupFuture.onComplete {
      case Success(_) => println("Database schema created successfully.")
      case Failure(e) =>
        println(s"Error creating database schema: ${e.getMessage}")
    }
  }
}

class Auctions(tag: Tag) extends Table[Auction](tag, "auctions") {
  def itemId = column[Int]("item_id", O.PrimaryKey)
  def startTime = column[Instant]("start_time")
  def endTime = column[Instant]("end_time")
  def startPrice = column[BigDecimal]("start_price")
  def endPrice = column[BigDecimal]("end_price")
  def * = (
    itemId,
    startTime,
    endTime,
    startPrice,
    endPrice
  ) <> (Auction.tupled, Auction.unapply)
}

class Bids(tag: Tag) extends Table[Bid](tag, "bids") {
  def auctionId = column[Int]("auction_id")
  def bidder = column[String]("bidder")
  def bidAmount = column[BigDecimal]("bid_amount")
  def * = (auctionId, bidder, bidAmount) <> (Bid.tupled, Bid.unapply)
}

case class Auction(
    itemId: Int,
    startTime: Instant,
    endTime: Instant,
    startPrice: BigDecimal,
    endPrice: BigDecimal
)
case class Bid(auctionId: Int, bidder: String, bidAmount: BigDecimal)
