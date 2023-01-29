import datetime


def lambda_handler(event, context):
    now = datetime.datetime.now()
    filename = "/mnt/lambda/filename-" + datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S") + ".txt"
    file = open(filename, "x")
    print("Start writing to ", filename)
    file.write("Content from Lambda function, at " + now.strftime("%d/%m/%Y, %H:%M:%S"))
    file.close()
    print("Done writing to ", filename)

