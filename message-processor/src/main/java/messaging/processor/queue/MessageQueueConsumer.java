package messaging.processor.queue;


import messaging.processor.processor.MessageProcessor;

/**
 * Created by mzagar on 11.9.2014.
 */
public interface MessageQueueConsumer {
    void start();
    void stop();
    void consume(MessageProcessor messageProcessor) throws MessageQueueConsumerException;
}
