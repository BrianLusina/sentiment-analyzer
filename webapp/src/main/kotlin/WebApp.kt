import io.ktor.application.*
import io.ktor.client.HttpClient
import io.ktor.client.engine.apache.Apache
import io.ktor.client.request.post
import io.ktor.features.ContentNegotiation
import io.ktor.gson.gson
import io.ktor.http.*
import io.ktor.request.receive
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.util.url
import java.text.DateFormat


fun main(args: Array<String>) {
    val client = HttpClient(Apache)

    val server = embeddedServer(Netty, port = 8080) {

        install(ContentNegotiation){
            gson {
                setDateFormat(DateFormat.LONG)
                setPrettyPrinting()
            }
        }

        routing {

            get("/") {
                call.respondText("Sentiment Analyser!", ContentType.Text.Plain)
            }

            post("/sentiment"){
                val sentence = call.receive<SentenceEntity>()

                // post to logic service url
                val sentiment = client.post<SentimentEntity>(LOGIC_SERVICE_URL){
                    body = sentence
                }

                // respond to client (front end)
                call.respond(SentimentEntity(sentiment.sentence, sentiment.polarity))
            }
        }

    }
    server.start(wait = true)
}