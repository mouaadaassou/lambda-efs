import datetime


def lambda_handler(event, context):
    now = datetime.datetime.now()
    filename = "filename-" + datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S, %H:%M:%S") + ".txt"
    file = open("/lambda/" + filename, "x")
    file.write("Content from Lambda function, at " + now.strftime("%d/%m/%Y, %H:%M:%S"))

