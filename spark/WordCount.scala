import com.datastax.spark.connector._
import org.apache.spark.{SparkConf, SparkContext}

object WordCount {

  def main(args:Array[String]) : Unit = {

    val conf = new SparkConf(true).
      setAppName("Spark WordCount").setMaster("local").set("spark.cassandra.connection.host", "127.0.0.1")

    val sc = new SparkContext(conf)

    val sentences = sc.cassandraTable[(String)]("sentencesks", "sentences").select("sentence")

    val textRDD = sc.parallelize(List(sentences.fold("")((f: String, s: String) => f + s)))

    val splits = textRDD.flatMap(line => line.split(" ")).map(word =>(word,1))
    val counts = splits.reduceByKey((x,y)=>x+y)

    counts.saveToCassandra("sentencesks", "wordcount", SomeColumns("word", "count"))

  }
}