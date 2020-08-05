import java.util.UUID

import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocol
import scala.util.Random
import java.util.UUID.randomUUID
import java.time.LocalDate

import scala.concurrent.duration._

class elasticsearch extends Simulation {

    private val baseUrl = "http://10.118.23.39:9200";
    private val contentType = "application/json"
    private val reqBodyRTS=ElFileBody("elasticsearch.json")
    val httpProtocol: HttpProtocol = http.baseUrl(baseUrl).inferHtmlResources().contentTypeHeader(contentType)
    //.shareConnections

    val scnWRITE: ScenarioBuilder = scenario("WriteSimulation")
        .exec(session => session.set("randomProductId1", randomStr(3)))
        .exec(session => session.set("randomProductId2", randomStr(3)))
        .exec(session => session.set("randomProductId3", randomStr(3)))
        .exec(session => session.set("randomProductId4", randomStr(3)))
        .exec(session => session.set("randomProductId5", randomStr(3)))
        .exec(session => session.set("randomProductId6", randomStr(3)))
        .exec(session => session.set("randomProductId7", randomStr(3)))
        .exec(session => session.set("randomProductId8", randomStr(3)))
        .exec(session => session.set("randomProductId9", randomStr(3)))
        .exec(session => session.set("randomProductId10", randomStr(3)))
        .exec(session => session.set("randomProductId11", randomStr(3)))
        .exec(session => session.set("randomProductId12", randomStr(3)))
        .exec(session => session.set("randomProductId13", randomStr(3)))
        .exec(session => session.set("randomProductId14", randomStr(3)))
        .exec(session => session.set("randomProductId15", randomStr(3)))
        .exec(session => session.set("randomProductId16", randomStr(3)))
        .exec(session => session.set("randomProductId17", randomStr(3)))
        .exec(session => session.set("randomProductId18", randomStr(3)))
        .exec(session => session.set("randomProductId19", randomStr(3)))
        .exec(session => session.set("randomProductId20", randomStr(3)))
        .exec(session => session.set("randomCustomerId", randomStr(6)))
        .exec(session => session.set("randomOrderId", UUID.randomUUID().toString))
        .exec(session => session.set("randomDate", getRandomDate()))
        .exec(session => session.set("randomQuantity1", randomInt()))
        .exec(session => session.set("randomQuantity2", randomInt()))
        .exec(session => session.set("randomQuantity3", randomInt()))
        .exec(session => session.set("randomQuantity4", randomInt()))
        .exec(session => session.set("randomQuantity5", randomInt()))
        .exec(session => session.set("randomQuantity6", randomInt()))
        .exec(session => session.set("randomQuantity7", randomInt()))
        .exec(session => session.set("randomQuantity8", randomInt()))
        .exec(session => session.set("randomQuantity9", randomInt()))
        .exec(session => session.set("randomQuantity10", randomInt()))
        .exec(session => session.set("randomQuantity11", randomInt()))
        .exec(session => session.set("randomQuantity12", randomInt()))
        .exec(session => session.set("randomQuantity13", randomInt()))
        .exec(session => session.set("randomQuantity14", randomInt()))
        .exec(session => session.set("randomQuantity15", randomInt()))
        .exec(session => session.set("randomQuantity16", randomInt()))
        .exec(session => session.set("randomQuantity17", randomInt()))
        .exec(session => session.set("randomQuantity18", randomInt()))
        .exec(session => session.set("randomQuantity19", randomInt()))
        .exec(session => session.set("randomQuantity20", randomInt()))
        .exec(http("es_write_${HOSTNAME}")
        //.post(session => s"/orders/_doc/" + session("randomOrderId").as[String] + "?routing=" + session("randomCustomerId").as[String])
        //.post(session => s"/orders/_doc/" + session("randomOrderId").as[String])
        .post(session => s"/orders/_doc/?pretty")
        .body(reqBodyRTS).asJson
        .header("Content-Type",session => contentType)
        .check(status.is(201)))
  
    val scnSEARCH: ScenarioBuilder = scenario("SearchSimulation")
        .exec(session => session.set("randomCustomerId", randomStr(6)))
        .exec(http("es_search_namesuffix")
        .get(session => s"/orders/_search?q=customerId:" + session("randomCustomerId").as[String] + "&routing=" + session("randomCustomerId").as[String])
        .check(status.is(200)))

    setUp(
      scnWRITE.inject(
        constantUsersPerSec(1) during (10 seconds)
        ,incrementUsersPerSec(1)
        .times(100)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(100) during (300 minutes)
      )
      .protocols(httpProtocol)
      /*,scnSEARCH.inject(
        constantUsersPerSec(1) during (10 seconds)
        ,incrementUsersPerSec(200)
        .times(10)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(2000) during (10 minutes)
        ,incrementUsersPerSec(5)
        .times(20)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(300)
      )
      .protocols(httpProtocol)*/
    )
    .maxDuration(300 minutes);




    def getRandomDate () : String = {
      return LocalDate.of(2019-Random.nextInt(2),1+Random.nextInt(11),1+Random.nextInt(27)).toString
    }

    def randomStr(length: Int) = scala.util.Random.alphanumeric.take(length).mkString
    def randomInt() = scala.util.Random.nextInt()

}
