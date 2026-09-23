package openapi_test

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/authzen/access.go/openapi"
)

func TestHandler(t *testing.T) {
	handler := http.HandlerFunc(openapi.OpenAPIHandler)

	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)

	resp, err := http.Get(server.URL) //nolint:noctx
	requiredNoError(t, err)
	t.Cleanup(func() { _ = resp.Body.Close() })

	requiredEqual(t, http.StatusOK, resp.StatusCode)

	contentType := resp.Header.Get("Content-Type")
	requiredEqual(t, "application/json", contentType)

	body, err := io.ReadAll(resp.Body)
	requiredNoError(t, err)

	t.Logf("Response: %s", body)
}

func requiredNoError(t *testing.T, err error) {
	t.Helper()

	if err != nil {
		t.Errorf("error %v", err)
		t.FailNow()
	}
}

func requiredEqual[T comparable](t *testing.T, expected, actual T) {
	t.Helper()

	if expected != actual {
		t.Errorf("expected %v, actual %v", expected, actual)
		t.FailNow()
	}
}
