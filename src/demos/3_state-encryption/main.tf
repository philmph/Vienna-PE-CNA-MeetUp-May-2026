resource "local_file" "hello" {
  content  = "OpenTofu state encryption demo — this content is visible in the app but encrypted at rest."
  filename = "${path.module}/output/hello.txt"
}
