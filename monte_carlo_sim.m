function y = monte_carlo_sim(no_of_servers, no_of_customers, randomizer)

    % Error handling for missing parameters
    if (~isset('no_of_servers'))
        error('First param (no_of_servers) is missing. It must be between 1 and 3. E.g. simulation(2, 10, "LCG").');
    elseif (~isset('no_of_customers'))
        error('Second param (no_of_customers) is missing. It must be more than or equal to 1. E.g. simulation(2, 10, "LCG").');
    elseif(~isset('randomizer'))
        error('Third param (randomizer) is missing. It must be either LCG, MLCG, ALCG, UDG, or EDG. E.g. simulation(2, 10, "LCG").');
    end

    % Error handling for wrong input
    if (no_of_servers < 1 || no_of_servers > 3)
        error('Number of servers must be between one and three.');
    elseif (no_of_customers < 1)
        error('Number of customers must be more than or equal to one.');
    elseif (~(strcmp(randomizer, 'LCG') || strcmp(randomizer, 'MLCG') || strcmp(randomizer, 'ALCG') || strcmp(randomizer, 'UDG') || strcmp(randomizer, 'EDG')))
        error('Randomizer must be either LCG, MLCG, ALCG, UDG, or EDG.');
    end

    printf('\n\n');
    disp('|===========================================================================================|')
    disp('|                               MONTE CARLO QUEUE SIMULATION                                |')
    disp('|===========================================================================================|')
    printf('\n');
    disp('1. Service Time Table');
    disp('2. Inter-Arrival Time Table');
    disp('3. Item Table');
    disp('4. Simulation Table');
    disp('5. Counter Status');
	disp('6. Evaluation of Results');
    disp('7. Conclusion');
    printf('\n\n');
	
    % Constants
	no_of_service_times = 5;
	no_of_inter_times   = 8;
	no_of_items         = 4;
	
	% Generate RN for service times, inter-arrival times and items
    rn_cust_service_times = feval(randomizer, no_of_customers, 1, 100);
    rn_cust_inter_times   = feval(randomizer, no_of_customers, 1, 1000);
    rn_cust_item_service  = feval(randomizer, no_of_customers, 1, 100);
	
    % Store all the service times of each server
	server_1 = zeros(1, no_of_customers + 1);
    server_2 = zeros(1, no_of_customers + 1);
    server_3 = zeros(1, no_of_customers + 1);
    
    % Indicate server number
    server_1(1) = 1;
    server_2(1) = 2;
    server_3(1) = 3;
    
    disp('|===========================================================================================|')
    disp('|                                 (1) SERVICE TIME TABLE                                    |')
    disp('|===========================================================================================|')
    printf('\n\n');
    for i = 1 : no_of_servers;

		% Generate RN to be used to determine range
        rn_service_times = zeros(1, no_of_service_times);
        for j = 1 : no_of_service_times;
            rn_service_times(j) = feval(randomizer, 1, 1, 100);
        end
        total_rn_service_times = sum(rn_service_times); 
        
		% Find range for each service time
        range_service_times = zeros(1, no_of_service_times);
        for j = 1 : no_of_service_times;
            range_service_times(j) = round(100 * rn_service_times(j) / total_rn_service_times);
            
            if (j >= 2);
                range_service_times(j) = range_service_times(j) + range_service_times(j - 1);
            end
        end
        range_service_times = range_service_times + (100 - range_service_times(no_of_service_times)); 
        
		% Find first number in range for each service time
        first_range_service_times = zeros(1, no_of_service_times);
        first_range_service_times(1) = 1;
        for j = 2 : no_of_service_times;
			first_range_service_times(j) = range_service_times(j - 1) + 1; 
        end
		
        % Find last number in range for each service time
        last_range_service_times = zeros(1, no_of_service_times);
        last_range_service_times(no_of_service_times) = 100;
        for j = 1 : no_of_service_times - 1;
            last_range_service_times(j) = first_range_service_times(j + 1) - 1;
        end
        
		% Find CDF of each service time
        CDF_service_times = zeros(1, no_of_service_times);
		CDF_service_times = range_service_times / 100;
		
		% Find probability of each service time
        probability_service_times = zeros(1, no_of_service_times);
        probability_service_times(1) = CDF_service_times(1);
        for j = 2 : no_of_service_times;
            probability_service_times(j) = CDF_service_times(j) - CDF_service_times(j - 1);
        end
        
		% Display service time table
        printf('                 Counter %d Service Time Table\n', i)
        disp('+------------------------------------------------------------+');
        disp('|  Service Time  |  Probability  |   CDF    |     Range      |');
        disp('+------------------------------------------------------------+');
        min_service_time(1) = 1 + i;
        for j = 1 : no_of_service_times;            
            printf('|\t\t\t\t\t\t%2d\t\t\t\t\t\t\t\t|\t\t\t\t\t\t%2.2f\t\t\t\t\t|\t\t\t%2.2f\t\t\t|\t\t\t%3d - %3d\t\t\t\t|\n',[min_service_time(j), probability_service_times(j), CDF_service_times(j), first_range_service_times(j), last_range_service_times(j)]);
            disp('+------------------------------------------------------------+');
            min_service_time(j + 1) = min_service_time(j) + 1;
        end
        printf('\n\n');
		
        % Find each server's service times
		for k = 2 : no_of_customers + 1
			for m = 1 : no_of_service_times;
                % If current RN service time falls between the first number and the last number in a service time range
				if (rn_cust_service_times(k - 1) >= first_range_service_times(m) && rn_cust_service_times(k - 1) <= last_range_service_times(m))
				% then current server's service time is the service time corresponded to the range	
                    if (i == 1) % server 1
						server_1(k) = min_service_time(m);
					elseif (i == 2) % server 2
						server_2(k) = min_service_time(m);
					elseif (i == 3) % server 3
						server_3(k) = min_service_time(m);
					end
                % Note: server_1(1) = 1, server_2(1) = 2, server_3(1) = 3
                % These indicate server number
				end
			end
		end       		
                        
    end
    
    disp('|===========================================================================================|')
    disp('|                              (2) INTER-ARRIVAL TIME TABLE                                 |')
    disp('|===========================================================================================|')
    printf('\n\n');

    for i = 1 : 1 % for-loop used for indent
        % Generate RN to be used to determine range
        rn_inter_times = zeros(1, no_of_inter_times);
        for j = 1 : no_of_inter_times;
            rn_inter_times(j) = feval(randomizer, 1, 1, 1000);
        end
        total_rn_inter_times = sum(rn_inter_times);
        
        % Find range for each inter-arrival time
        range_inter_times = zeros(1, no_of_inter_times);
        for j=1:no_of_inter_times;
            range_inter_times(j) = round(1000 * rn_inter_times(j) / total_rn_inter_times);
            
            if(j >= 2);
                range_inter_times(j) = range_inter_times(j) + range_inter_times(j - 1);
            end
        end
        range_inter_times = range_inter_times + (1000 - range_inter_times(no_of_inter_times)); 
        
        % Find first number in range for each item
        first_range_inter_times = zeros(1, no_of_inter_times);
        first_range_inter_times(1) = 1;
        for j = 2 : no_of_inter_times;
            first_range_inter_times(j) = range_inter_times(j - 1) + 1;
        end
        
        % Find last number in range for each item
        last_range_inter_times = zeros(1, no_of_inter_times);
        last_range_inter_times(no_of_inter_times) = 1000;
        for j = 1 : no_of_inter_times - 1;
            last_range_inter_times(j) = first_range_inter_times(j + 1) - 1;
        end
        
        % Find CDF for each inter-arrival time
        CDF_inter_times = zeros(1, no_of_inter_times);
        CDF_inter_times = range_inter_times / 1000;
        
        % Find probability for each inter-arrival time    
        probability_inter_times = zeros(1, no_of_inter_times);
        probability_inter_times(1) = CDF_inter_times(1);
        for j = 2 : no_of_inter_times;
            probability_inter_times(j) = CDF_inter_times(j) - CDF_inter_times(j - 1);
        end
        
        % Display inter-arrival time table
        disp('                      Inter-Arrival Time Table');
        disp('+------------------------------------------------------------------+');
        disp('|  Inter-arrival Time  |  Probability  |   CDF    |     Range      |');
        disp('+------------------------------------------------------------------+');
        min_inter_times(1) = 1;
        for j = 1 : no_of_inter_times;            
            printf('|\t\t\t\t\t\t\t\t\t\t%2d\t\t\t\t\t\t\t\t\t\t|\t\t\t\t\t\t%2.2f\t\t\t\t\t|\t\t\t%2.2f\t\t\t|\t\t\t%3d - %4d\t\t\t|\n',[min_inter_times(j), probability_inter_times(j), CDF_inter_times(j), first_range_inter_times(j), last_range_inter_times(j)]);
            min_inter_times(j + 1) = min_inter_times(j) + 1;
            disp('+------------------------------------------------------------------+');
        end
        printf('\n\n'); 
	
    end	
	
    disp('|===========================================================================================|')
    disp('|                                    (3) ITEM TABLE                                         |')
    disp('|===========================================================================================|')
    printf('\n\n');
	for i = 1 : 1; % for-loop used for indent

		% Generate RN to be used to determine range
		rn_items = zeros(1, no_of_items);
        for j = 1 : no_of_items;
            rn_items(j) = feval(randomizer, 1, 1, 100); 
        end
        total_rn_items = sum(rn_items); 
		
		% Generate range for each item
        range_items = zeros(1, no_of_items);
        for j = 1 : no_of_items;
            range_items(j) = round(100 * rn_items(j) / total_rn_items);
            
            if (j >= 2);
                range_items(j) = range_items(j) + range_items(j - 1);
            end
        end
        range_items = range_items + (100 - range_items(no_of_items));
        
		% Find first number in range for each item
        first_range_items = zeros(1, no_of_items);
        first_range_items(1) = 1;
        for j = 2 : no_of_items;
            first_range_items(j) = range_items(j - 1) + 1; 
        end
        
		% Find last number in range for each item
        last_range_items = zeros(1, no_of_items);
        last_range_items(no_of_items) = 100;
        for j = 1 : no_of_items - 1;
            last_range_items(j) = first_range_items(j + 1) - 1;
        end
		
        % Find CDF of each item
        CDF_items = zeros(1, no_of_items);
		CDF_items = range_items / 100;
		
		% Find probability of each item
        probability_items = zeros(1, no_of_items);
        probability_items(1) = CDF_items(1);
        for j = 2 : no_of_items;
            probability_items(j) = CDF_items(j) - CDF_items(j - 1);
        end
        
		% Generate price for each item
        price_items = [];
        for j = 1 : no_of_items;
            price_items(j) = feval(randomizer, 1, 1, 10);
        end
        
		% Display item table
        printf('                              Item Table\n');
        disp('+---------------------------------------------------------------------+');
        disp('|  Item Number  |  Probability  |   CDF    |     Range      |  Price  |');
        disp('+---------------------------------------------------------------------+');
        min_item_no(1) = 1;
        for j = 1 : no_of_items;            
            printf('|\t\t\t\t\t\t%2d\t\t\t\t\t\t\t|\t\t\t\t\t\t%2.2f\t\t\t\t\t|\t\t\t%2.2f\t\t\t|\t\t\t%3d - %3d\t\t\t\t|\t\t\t%2d\t\t\t\t|\n',[min_item_no(j), probability_items(j), CDF_items(j), first_range_items(j), last_range_items(j), price_items(j)]);
            min_item_no(j + 1) = min_item_no(j) + 1;
            disp('+---------------------------------------------------------------------+');
        end
        printf('\n\n');  
        
    end
    
    disp('|===========================================================================================|')
    disp('|                                  (4) SIMULATION TABLE                                     |')
    disp('|===========================================================================================|')
    printf('\n\n');
    for i = 1 : 1 % for-loop used for indent

        % Find customer inter-arrival times 
        rn_cust_inter_times(1) = 0;
    	cust_inter_times = zeros(1, no_of_customers);
    	for customer = 2 : no_of_customers
    		for range = 1 : no_of_inter_times
                % If current RN inter-arrival time falls between the first number and the last number in a inter-arrival time range
    			if (rn_cust_inter_times(customer) >= first_range_inter_times(range) && rn_cust_inter_times(customer) <= last_range_inter_times(range))
    			% then current customer's inter-arrival time is the inter-arrival time corresponded to the range	
                    cust_inter_times(customer) = min_inter_times(range);
    			end
    		end
    	end
    	
        % Variables to be determined in the for-loop below
    	cust_arrival_times    = zeros(1, no_of_customers); % Arrival Time
    	available_server      = zeros(1, no_of_customers); % Server available for current customer
        cust_service_duration = zeros(1, no_of_customers); % Service Time (Duration)
    	service_time_begin    = zeros(1, no_of_customers); % Time Service Begins
    	service_time_end      = zeros(1, no_of_customers); % Time Service Ends
    	cust_queue_times      = zeros(1, no_of_customers); % Time in Queue
    	system_time_spend     = zeros(1, no_of_customers); % Time Spend in System
        customer_server       = zeros(1, no_of_customers); % Server Number
    	server_end_times      = zeros(1, no_of_servers); % Server End Times
        item_service_no       = zeros(1, no_of_customers); % Item Number
        server_1_time_spent   = zeros(1, no_of_customers); % Time spent in server one
        server_2_time_spent   = zeros(1, no_of_customers); % Time spent in server two
        server_3_time_spent   = zeros(1, no_of_customers); % Time spent in server three
        total_customer_server_1 = 0; % Number of customers in server one
        total_customer_server_2 = 0; % Number of customers in server two
        total_customer_server_3 = 0; % Number of customers in server three
		total_sales = zeros(1, no_of_servers); % Total sales of each server
        
        for customer = 1 : no_of_customers
            % Find customer arrival times
    	    if (customer >= 2)
                % Arrival Time(n) = Arrival Time(n - 1) + Inter-Arrival Time(n)
                % Arrival Time(1) = 0
    			cust_arrival_times(customer) = cust_arrival_times(customer - 1) + cust_inter_times(customer);	
    		end
    		
    		available_server = [0 (no_of_customers*999)]; % Initialize the server [server_number server_end_times_of_previous_customer]
            
			% Decide the server for current customer
            for i = 1 : no_of_servers;
                if (server_end_times(i) < available_server(2));   
                    available_server = [i server_end_times(i)];
                end
            end

            % For first customer in first server, the server doesn't have end times yet
            if customer == 1;
                available_server = [1 0];
            end
           
            % Customer's Server Number and Customer's Server End Times
            customer_server(customer) = available_server(1);
            chosen_server_end_times = available_server(2);
            

            % Customer service time (duration) is the service time in particular server
            if customer_server(customer) == 1 
				cust_service_duration(customer) = server_1(customer + 1);
			elseif customer_server(customer) == 2
				cust_service_duration(customer) = server_2(customer + 1);
			elseif customer_server(customer) == 3
				cust_service_duration(customer) = server_3(customer + 1);
			end
    		
            % Time Service Begins = MAX(Arrival Time, Server End Times)
            % Time Service Ends = Time Service Begins + Service Duration
            % Time in Queue = Service Time Begins - Arrival Time
            % Time Spend in System = Time Service Ends - Arrival Time
            % Server End Times = Time Service Ends (to keep track of previous customer's service end time)
    		service_time_begin(customer) = max([cust_arrival_times chosen_server_end_times]);
            service_time_end(customer)   = service_time_begin(customer) + cust_service_duration(customer);
            cust_queue_times(customer)   = service_time_begin(customer) - cust_arrival_times(customer);
    		system_time_spend(customer)  = service_time_end(customer) - cust_arrival_times(customer);
    		server_end_times(available_server(1)) = service_time_end(customer);
    		
            % Find item number
    		for i = 1 : no_of_items
                % If current RN item falls between the first number and the last number in a range
    			if (rn_cust_item_service(customer) >= first_range_items(i) && rn_cust_item_service(customer) <= last_range_items(i))
    			% then current customer's item number is the item number corresponded to the range	
                    item_service_no(customer) = min_item_no(i);
                end
    		end
    		
            % Generate RN item quantity between 1 and 11
    		item_quantity(customer) = round(rand() * 10) + 1;
    		
            % Total Price = Item Quantity * Price
    		total_price(customer) = item_quantity(customer) * price_items(item_service_no(customer));
			
            % Find time spent in each server, number of customers and total sales of each server has
			% Server Time Spent(n) = Server Time Spent(n) +  Service Duration(n)
            if customer_server(customer) == 1 
				server_1_time_spent(customer) = server_1_time_spent(customer) + cust_service_duration(customer);
                total_customer_server_1 = total_customer_server_1 + 1;
				total_sales(1) = total_sales(1) + total_price(customer);
			elseif customer_server(customer) == 2
				server_2_time_spent(customer) = server_2_time_spent(customer) + cust_service_duration(customer);
                total_customer_server_2 = total_customer_server_2 + 1;
				total_sales(2) = total_sales(2) + total_price(customer);
			elseif customer_server(customer) == 3
				server_3_time_spent(customer) = server_3_time_spent(customer) + cust_service_duration(customer);
                total_customer_server_3 = total_customer_server_3 + 1;
				total_sales(3) = total_sales(3) + total_price(customer);
			end
			
    	end
    	
    	% Display simulation table
        disp('                                             Simulation Table');
    	disp('+--------------------------------------------------------------------------------------------------------------+');
        disp('|  n |RN for |Inter- |Arrival|RN for |Counter|Service|Time   |Time   |Waiting|Time | RN   | Item | Qty | Total |')
        disp('|    |Inter- |Arrival|Time   |Service|       |Time   |Service|Service|Time   |Spend| for  | Num  |     | Price |')
        disp('|    |Arrival|Time   |       |Time   |       |       |Begins |Ends   |       |     | Item |      |     |       |')
        disp('|    |Time   |       |       |       |       |       |       |       |       |     |      |      |     |       |')
    	disp('+--------------------------------------------------------------------------------------------------------------+');
        for i = 1 : no_of_customers
            printf('|\t%2d\t|\t\t%3d\t\t|\t\t\t%d\t\t\t|\t\t%2d\t\t\t|\t\t%2d\t\t\t|\t\t\t%d\t\t\t|\t\t%2d\t\t\t|\t\t%2d\t\t\t|\t\t%2d\t\t\t|\t\t%2d\t\t\t|\t%2d\t\t|\t%3d\t\t|\t\t%2d\t\t|\t%2d\t\t|\t\t%3d\t\t|\n', i, rn_cust_inter_times(i), cust_inter_times(i), cust_arrival_times(i), rn_cust_service_times(i), customer_server(i), cust_service_duration(i), service_time_begin(i), service_time_end(i), cust_queue_times(i), system_time_spend(i), rn_cust_item_service(i), item_service_no(i), item_quantity(i), total_price(i));
    	    disp('+--------------------------------------------------------------------------------------------------------------+');  
        end
        printf('\n\n');

	end
	
    disp('|===========================================================================================|')
    disp('|                                  (5) COUNTER STATUS                                       |')
    disp('|===========================================================================================|')
    printf('\n\n');
    for i = 1 : 1 % for-loop used for indent
        
        for customer = 1 : no_of_customers;
            printf('Arrival of customer %d at minute %d and queues at Counter %d.\n', customer, cust_arrival_times(customer), customer_server(customer));
            printf('Service for customer %d takes %d minute.\n', customer, cust_service_duration(customer));
		    printf('Departure of customer %d at minute %d.\n\n', customer, service_time_end(customer));
        end
        printf('\n\n');

    end
    
    disp('|===========================================================================================|')
    disp('|                            (6) EVALUATION OF RESULTS                                      |')
    disp('|===========================================================================================|')
	printf('\n\n');
    for i = 1 : 1 % for-loop used for indent
        
        % Variables to be determined in the for-loop below
        total_time_spent = zeros(1, no_of_servers); % Total Time Spend in Server 
        total_customer = zeros(1, no_of_servers); % Total Customers in Server
        server_busy = zeros(1, no_of_servers);  % Server Busy

        for server = 1 : no_of_servers;
            % Total time spend, total customers and total sales of each server
            if (server == 1)
                total_time_spent(1) = sum(server_1_time_spent);
                total_customer(1) = total_customer_server_1;
            elseif(server == 2)
                total_time_spent(2) = sum(server_2_time_spent);
                total_customer(2) = total_customer_server_2;
            elseif(server == 3)
                total_time_spent(3) = sum(server_3_time_spent);
                total_customer(3) = total_customer_server_3;
            end
            % Server Busy = Total Time Spend in Server / Final Service Time Ends
            printf('Counter %d spent %d minutes serving %d customers.\n', server, total_time_spent(server), total_customer(server));
			printf('Sales generated by Counter %d = RM %6.2f \n', server, total_sales(server));
            server_busy(server) = (total_time_spent(server) / service_time_end(no_of_customers)) * 100;
            printf('Percentage of time Counter %d was busy: %2.2f percent.\n\n', server, server_busy(server));
        end
        printf('\n');

        % Average Waiting Time = Time in Queue / Total Customers
        % Probability of Queueing Up = Total Time in Queue / Total Customers
        avg_waiting_time = mean(cust_queue_times);
        probability_of_customers_queue_up = sum(cust_queue_times) / no_of_customers;
    	printf('Average waiting time of a customer in queue: %5.2f\n', [avg_waiting_time])
        printf('Probalility that a customer has to wait in the queue: %5.2f\n', [probability_of_customers_queue_up]);

        % Average Service Time = Service Time (Duration) / Total Customers
        % Average Inter-Arrival Time = Inter-Arrival Times / Total Customers
        % Average Time Spend in System = Total Time Spend in System / Total Customers
        customer_avg_service_time = mean(cust_service_duration);
        customer_avg_interarrival_time = mean(cust_inter_times);
        customer_avg_spent_time = sum(total_time_spent) / no_of_customers;
        printf('Average service time: %5.2f\n', customer_avg_service_time);
    	printf('Average interarrival time: %5.2f\n', customer_avg_interarrival_time);
    	printf('Average time customer spent at counter: %5.2f\n', customer_avg_spent_time);
        printf('\n\n');
		
	end
		
		disp('|===========================================================================================|')
		disp('|                                  (7) CONCLUSION                                           |')
		disp('|===========================================================================================|')
		printf('\n\n');
	for i = 1 : 1 % for-loop used for indent
		
		% Determine the chance of waiting in a queue by probability of customer queuing up
		if (probability_of_customers_queue_up <= 0.25)
			disp('Customers have a low chance of waiting in queue.')
		elseif (probability_of_customers_queue_up > 0.25 && probability_of_customers_queue_up <= 0.50)
			disp('Customers have a moderate chance of waiting in queue.')
		elseif (probability_of_customers_queue_up > 0.50 && probability_of_customers_queue_up <= 0.75)
			disp('Customers have a high chance of waiting in queue.')
		else
			disp('Customers have a very high chance of waiting in queue.')            
		end
		
		printf('\n\n');

    end