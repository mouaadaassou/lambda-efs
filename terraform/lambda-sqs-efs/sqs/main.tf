resource "aws_sqs_queue" "sqs_queue" {
  count                      = length(var.queue_names)
  name                       = var.queue_names[count.index]
  delay_seconds              = var.queue_delay_seconds
  visibility_timeout_seconds = var.queue_visibility_timeout_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_deadletter[count.index].arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "sqs_queue_deadletter" {
  count = length(var.queue_names)
  name  = "${var.queue_names[count.index]}-dlq"
}