DELIMITER //
CREATE PROCEDURE banking_tp.`SP_Transfer` (
	-- Truyền giá trị người chuyển, người nhận tiền và số tiền chuyển mà ta nhập vào
	IN sender_id INT,
    IN recipient_id INT,
    IN transfer_amount DECIMAL(12,0),
    OUT message VARCHAR(50)
)
BEGIN
	-- Khai bao bien
	DECLARE senderCreadit DECIMAL (12,0) DEFAULT 0;
    DECLARE fees INT DEFAULT 10;
    DECLARE fees_amount DECIMAL (12,0) DEFAULT 0;
    DECLARE transaction_amount DECIMAL (12,0) DEFAULT 0;
    
    -- Biến tạm
    DECLARE _rollback BOOL DEFAULT 0;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _rollback = 1;
    
    -- Bắt đầu tiến trình xử lý
    START TRANSACTION;
    
    IF EXISTS (SELECT 1 FROM customer WHERE id = sender_id)
    THEN
		IF EXISTS (SELECT 1 FROM customer WHERE id = recipient_id)
        THEN
			SELECT balance
            INTO senderCreadit
            FROM customer
            WHERE id = sender_id;
            
            SET fees_amount = transfer_amount * fees / 100;
            SET transaction_amount = transfer_amount + fees_amount;
            
            IF(senderCreadit >= transaction_amount AND transfer_amount >= 50000)
            THEN 
					
					-- Chuyển tiền
                    UPDATE customer c
                    SET c.balance = c.balance - transfer_amount
                    WHERE c.id = sender_id;
                    
                    -- Cập nhật giá trị balance từ bảng customer
                    -- Nhận tiền
					UPDATE customers c
					SET c.balance = c.balance + transfer_amount
					WHERE c.id = recipient_id;
                    
                    SET message = 'không hợp lệ';
                    
				IF _rollback THEN
					ROLLBACK;
				ELSE
					SET message = 'Chuyển tiền thành công';
					COMMIT;
				END IF;	
                
			ELSE
				SET message = 'Số tiền trong tài khoản không đủ để chuyển khoản';
			END IF;
		ELSE 
			SET message = 'Thông tin người nhận không hợp lệ';
		END IF;
	ELSE 
		SET message = 'Thông tin người gửi không hợp lệ';
    END IF;
END//

DELIMITER;

DELIMITER //
            
            
            
            
            
DELIMITER //

CREATE PROCEDURE banking_tp.`SP_Transfer`(
    IN senderId INT,
    IN recipientId INT,
    IN transferAmount DECIMAL(12,0),
    OUT message VARCHAR(50)
)

BEGIN

    DECLARE senderCredit DECIMAL(12,0) DEFAULT 0;
    DECLARE fees INT DEFAULT 10;
    DECLARE feesAmount DECIMAL(12,0) DEFAULT 0;
    DECLARE transactionAmount DECIMAL(12,0) DEFAULT 0;
    
    DECLARE _rollback BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _rollback = 1;
    
    START TRANSACTION;
    
    IF EXISTS (SELECT 1 FROM customers WHERE id = senderId)
	THEN
		IF EXISTS (SELECT 1 FROM customers WHERE id = recipientId)
		THEN
			SELECT balance 
			INTO senderCredit
			FROM customers
			WHERE id = senderId;
            
            SET feesAmount = transferAmount * fees / 100;
            SET transactionAmount = transferAmount + feesAmount;

			IF (senderCredit >= transactionAmount AND transferAmount >= 50) 
            THEN
				
					SET message = 'Invalid transaction information';
                
					UPDATE customers c
					SET c.balance = c.balance - transactionAmount
					WHERE c.id = senderId;
					
					UPDATE customers c
					SET c.balance = c.balance + transferAmount
					WHERE c.id = recipientId;
				IF _rollback THEN
					ROLLBACK;
				ELSE
					SET message = 'Transfer successful';
					
					COMMIT;
				END IF;	
			ELSE
				SET message = 'The Sender balance is not enough to make the transfer';
			END IF;
		ELSE 
			SET message = 'Invalid Recipient information';
		END IF;
	ELSE 
		SET message = 'Invalid Sender information';
    END IF;
END//

DELIMITER;

DELIMITER //