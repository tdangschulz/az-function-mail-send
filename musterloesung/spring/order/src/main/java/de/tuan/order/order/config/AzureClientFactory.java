package de.tuan.order.order.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.azure.messaging.servicebus.ServiceBusClientBuilder;
import com.azure.messaging.servicebus.ServiceBusSenderClient;
import com.azure.storage.queue.QueueClient;
import com.azure.storage.queue.QueueClientBuilder;

@Configuration
public class AzureClientFactory {

    private final static String queueName = "order-accepted-queue";

    private final static String queueEndpoint = "DefaultEndpointsProtocol=https;AccountName=orderstoragetds;AccountKey=A8CdTtcYk1e0GKR+70IAFXGfTiaUhe5o+YztGPc/GrhdyGuuKMHCZ1lzB5eFDWAAF01HWLowwjhH+ASt67Iu7A==;EndpointSuffix=core.windows.net";
    private final static String topicEndpoint = "Endpoint=sb://bus-order-weu-tds.servicebus.windows.net/;SharedAccessKeyName=spring-app;SharedAccessKey=1VXl63bxAzO43Wl21ZYf4v5hSmxmajVfd+ASbP0+8oI=;EntityPath=cancelorder";

    @Bean
    public QueueClient createQueueClient() {

        QueueClient queueClient = new QueueClientBuilder()

                .connectionString(queueEndpoint)
                .queueName(queueName)
                .buildClient();

        queueClient.createIfNotExists();

        return queueClient;
    }

    @Bean
    public ServiceBusSenderClient createServiceBusSenderClient() {
        var sender = new ServiceBusClientBuilder()
                // .proxyOptions(new ProxyOptions(ProxyAuthenticationType.NONE,
                // new Proxy(Type.HTTP, new InetSocketAddress("127.0.0.1", 9000)), null, null))
                .connectionString(topicEndpoint)
                .sender()
                .buildClient();
        return sender;
    }
}
