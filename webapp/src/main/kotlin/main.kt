import io.ktor.application.call
import io.ktor.application.install
import io.ktor.client.HttpClient
import io.ktor.client.engine.apache.Apache
import io.ktor.client.features.json.GsonSerializer
import io.ktor.client.features.json.JsonFeature
import io.ktor.client.request.post
import io.ktor.features.CORS
import io.ktor.features.ContentNegotiation
import io.ktor.features.DefaultHeaders
import io.ktor.gson.gson
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.contentType
import io.ktor.request.receive
import io.ktor.response.respond
import io.ktor.response.respondText
import io.ktor.routing.get
import io.ktor.routing.post
import io.ktor.routing.routing
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import java.text.DateFormat

fun main(args: Array<String>) {
    val client = HttpClient(Apache) {
        install(JsonFeature) {
            serializer = GsonSerializer()
        }
    }

    val server = embeddedServer(Netty, port = 8080) {

        install(ContentNegotiation) {
            gson {
                setDateFormat(DateFormat.LONG)
                setPrettyPrinting()
            }
        }

        install(DefaultHeaders){
            header("Access-Control-Allow-Origin", "*")
            header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE")
        }

        install(CORS){
            method(HttpMethod.Options)
        }

        routing {

            get("/") {
                call.respondText("Sentiment Analyser!", ContentType.Text.Plain)
            }

            post("/sentiment") {
                val sentence = call.receive<SentenceEntity>()

                // post to logic service url
                val sentiment = client.post<SentimentEntity>(LOGIC_SERVICE_URL) {
                    contentType(ContentType.Application.Json)
                    body = sentence
                }

                // respond to client (front end)
                call.respond(SentimentEntity(sentiment.sentence, sentiment.polarity))
            }
        }

    }
    server.start(wait = true)
}
