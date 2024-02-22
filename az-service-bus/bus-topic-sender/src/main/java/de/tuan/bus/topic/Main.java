package de.tuan.bus.topic;

import java.util.Arrays;
import java.util.List;

import com.azure.messaging.servicebus.ServiceBusClientBuilder;
import com.azure.messaging.servicebus.ServiceBusMessage;

/**
 * https://github.com/Azure/azure-sdk-for-java/blob/main/sdk/servicebus/azure-messaging-servicebus/README.md#send-messages
 */
public class Main {
    public static void main(String[] args) {

        try {
            var sender = new ServiceBusClientBuilder().connectionString(
                    "Endpoint=sb://bus-tuan-test.servicebus.windows.net/;SharedAccessKeyName=policy;SharedAccessKey=mHOZime/GYoVbMUqWT4RFsfaQYoRqsIUc+ASbJ1IW8g=;EntityPath=myfirsttopic")
                    .sender().topicName("myfirsttopic")
                    .buildClient();

            var msg1 = new ServiceBusMessage("topic-msg-1");
            msg1.getApplicationProperties().put("name", "tuan");
            var msg2 = new ServiceBusMessage("topic-msg-2");

            List<ServiceBusMessage> messages = Arrays.asList(
                    msg1,
                    msg2);

            sender.sendMessages(messages);
            sender.close();
        } catch (Exception e) {
            System.err.println("Ein Fehler ist aufgetreten: " + e.getMessage());
            e.printStackTrace();
        }

    }
}