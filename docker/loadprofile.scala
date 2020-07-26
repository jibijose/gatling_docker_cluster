import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class loadprofile extends Simulation {

  val httpProtocol = http
    .baseUrl("https://httpbin.org") // Here is the root for all relative URLs
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0")

  val scn100milli = scenario("Scenario delay 1 second delay") // A scenario is a chain of requests and pauses
    .exec(
      http("request_1_second_delay_namesuffix")
        .get("/delay/0.5")
      .check(status.is(200))
    );

  setUp(
    scn100milli.inject(
       constantUsersPerSec(10) during (1 minute),
       rampUsersPerSec(1) to 10 during(10 seconds),
       constantUsersPerSec(10) during(1 minutes)
     )
     .protocols(httpProtocol)
  )
  .maxDuration(2 minutes);

}
