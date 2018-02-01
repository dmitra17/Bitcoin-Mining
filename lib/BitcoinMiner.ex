defmodule BitcoinMiner do
    def main(args) do

        if String.length(List.first(args))<4 do            
            var1 = String.to_integer(List.first(args))
            BitcoinMiner.server_bitcoin(var1)

        else
            BitcoinMiner.client_bitcoin(List.first(args))
        end
        receive do
            {:st} -> IO.puts ""
        end
    end

    def server_bitcoin(k) do    
        {:ok, addrs} = :inet.getif
        {ip_gen, _, _} = Enum.at(addrs,0)
        {first, second, third, fourth} = ip_gen
        ip = "#{first}.#{second}.#{third}.#{fourth}"
        
        if ip == "127.0.0.1" do
            {:ok, addrs}= :inet.getif
            var2 = Enum.at(addrs,1)
            {ip_gen, _, _} = var2
            {first, second, third, fourth} = ip_gen
            ip = "#{first}.#{second}.#{third}.#{fourth}"
        end
        
        IO.puts "Server IP: " <> ip

        Node.start(String.to_atom("serv1@"<>ip))
        Node.set_cookie(Node.self(), :"cookiename")

        core_count1 = :erlang.system_info(:schedulers_online)
       
        BitcoinMiner.actor_spawn(ip, k, core_count1)
        
    end


    def actor_spawn(ip, k, no_of_cores) do
        if no_of_cores>0 do
            process_miner = Node.spawn(String.to_atom("serv1@"<>ip), BitcoinMiner, :miner, [k])
            process_listener = Node.spawn(String.to_atom("serv1@"<>ip), BitcoinMiner, :client_detection, [k,0])
            no_of_cores=no_of_cores-1
        end
        if no_of_cores>0 do
            actor_spawn(ip, k, no_of_cores)
        end
    end

    
    def miner(p) do
        BitcoinMiner.counter_rand(p)
        miner(p)
    end
    
    def client_detection(j, count)  do
        
        core_count2 = :erlang.system_info(:schedulers_online)
        if length(Node.list)>count do
            actor_spawn1(Enum.at(Node.list ,count), j, core_count2)           
           
            count = count+1
        end
        client_detection(j, count)
    end

    def actor_spawn1(clientmachine, k, noCores) do
        if noCores>0 do
            pid = Node.spawn(clientmachine, BitcoinMiner, :mining, [k] );
            send pid, {:message, "master"};
            noCores=noCores-1
        end
        if noCores>0 do
            actor_spawn1(clientmachine, k, noCores)
        end
    end



    def client_bitcoin(arg) do  
        {:ok, addrs} = :inet.getif
        {ip_gen, _, _} = Enum.at(addrs,0)
        {first, second, third, fourth} = ip_gen
        ip = "#{first}.#{second}.#{third}.#{fourth}"
        
        if ip == "127.0.0.1" do
            {:ok, addrs}= :inet.getif
            var2 = Enum.at(addrs,1)
            {ip_gen, _, _} = var2
            {first, second, third, fourth} = ip_gen
            ip = "#{first}.#{second}.#{third}.#{fourth}"
        end
        
        IO.puts "Client IP: " <> ip

        name = String.slice(SecureRandom.base64(4),0,3) <> "@"
    
        Node.start (String.to_atom(name<>ip))
        Node.set_cookie (:"cookiename")
        Node.connect(String.to_atom("serv1@"<>arg))    
    end
    
    def mining(k) do
        receive do
            (str) -> BitcoinMiner.counter_rand(k)
        end   
        mining(k)
    end

    
         
    
      def counter_rand(length) do
       

        
        ufid = "dmitra17;"
        
        s = String.slice(Integer.to_string(length), 0..0)
        prefix_str = String.duplicate("0", String.to_integer(s))
        
        randomstr = SecureRandom.base64(8)
        
        str = ufid<>SecureRandom.base64(8)
        str1 = Base.encode16(:crypto.hash(:sha256,str))    
       
        if String.starts_with?(str1, prefix_str) == true do
          IO.puts str<>"\t"<>str1
        end

        


      end
      
      
end