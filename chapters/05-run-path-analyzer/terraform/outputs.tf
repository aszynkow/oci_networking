output "path_test_internet_to_web_id" {
  description = "OCID of the internet-to-web-443 path analyzer test"
  value       = oci_vn_monitoring_path_analyzer_test.internet_to_web_443.id
}

output "path_test_internet_to_app_id" {
  description = "OCID of the internet-to-app-8080-blocked path analyzer test"
  value       = oci_vn_monitoring_path_analyzer_test.internet_to_app_8080.id
}

output "path_test_web_to_app_id" {
  description = "OCID of the web-to-app-8080-allowed path analyzer test"
  value       = oci_vn_monitoring_path_analyzer_test.web_to_app_8080.id
}

output "console_url_path_analyzer" {
  description = "Console URL to open Path Analyzer directly"
  value       = "https://cloud.oracle.com/networking/network-command-center/path-analyzer?region=${var.region}"
}
