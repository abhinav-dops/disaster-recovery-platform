package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type Record struct {
	ID        int       `json:"id"`
	Region    string    `json:"region"`
	Timestamp time.Time `json:"timestamp"`
}

var (
	mu      sync.Mutex
	records []Record
	counter int
)

const maxRecords = 10

var pageTpl = template.Must(template.New("status").Parse(`
<!DOCTYPE html>
<html>
<head><title>DR Status - {{.Region}}</title>
<meta http-equiv="refresh" content="5">
<style>
body { font-family: sans-serif; margin: 40px; background: #111; color: #eee; }
h1 { color: #4caf50; }
table { border-collapse: collapse; width: 100%; max-width: 600px; }
td, th { border: 1px solid #444; padding: 8px; text-align: left; }
.region-primary { color: #4caf50; }
.region-standby { color: #ff9800; }
</style>
</head>
<body>
<h1>Region: <span class="region-{{.Region}}">{{.Region}}</span></h1>
<p>Last write: {{.LastWrite}}</p>
<h3>Recent Records</h3>
<table>
<tr><th>ID</th><th>Region</th><th>Timestamp</th></tr>
{{range .Records}}
<tr><td>{{.ID}}</td><td>{{.Region}}</td><td>{{.Timestamp}}</td></tr>
{{end}}
</table>
</body>
</html>
`))

func main() {
	region := os.Getenv("REGION_ROLE")
	if region == "" {
		region = "unknown"
	}
	bucket := os.Getenv("S3_BUCKET")
	if bucket == "" {
		log.Fatal("S3_BUCKET environment variable is required")
	}

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("failed to load AWS config: %v", err)
	}
	s3Client := s3.NewFromConfig(cfg)

	// Background writer
	go func() {
		for {
			mu.Lock()
			counter++
			rec := Record{
				ID:        counter,
				Region:    region,
				Timestamp: time.Now().UTC(),
			}
			records = append([]Record{rec}, records...)
			if len(records) > maxRecords {
				records = records[:maxRecords]
			}
			mu.Unlock()

			data, _ := json.Marshal(rec)
			key := fmt.Sprintf("records/%s/%d.json", region, rec.ID)

			_, err := s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
				Bucket:      aws.String(bucket),
				Key:         aws.String(key),
				Body:        bytes.NewReader(data),
				ContentType: aws.String("application/json"),
			})
			if err != nil {
				log.Printf("failed to write to S3: %v", err)
			}

			time.Sleep(5 * time.Second)
		}
	}()

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "OK")
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		lastWrite := "never"
		if len(records) > 0 {
			lastWrite = records[0].Timestamp.Format(time.RFC3339)
		}
		pageTpl.Execute(w, map[string]interface{}{
			"Region":    region,
			"LastWrite": lastWrite,
			"Records":   records,
		})
	})

	log.Println("Starting server on :80")
	log.Fatal(http.ListenAndServe(":80", nil))
}