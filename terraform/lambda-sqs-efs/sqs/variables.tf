variable "queue_names" {
  type        = list(string)
  description = "list of queue names to provision"
}

variable "queue_delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
}
variable "queue_visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout for the queue"
}