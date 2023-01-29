output "sqs_queues_arn" {
  value = aws_sqs_queue.sqs_queue.*.arn
}