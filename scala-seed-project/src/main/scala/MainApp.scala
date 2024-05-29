// File: src/main/scala/MainApp.scala

import scala.concurrent.Await
import scala.concurrent.duration._
import scala.util.{Failure, Success}

object MainApp {
  def main(args: Array[String]): Unit = {
    println("Initializing database schema...")
    DatabaseSchema.createSchema()
  }
}
