export ETH_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/mbUxF1X2f-iSsWF24sS7sznhIX5unTI7"

for i in {41200..41220}
do
  # 执行 cast call 并捕获返回值
  RESULT=$(cast call 0xb5858B8EDE0030e46C0Ac1aaAedea8Fb71EF423C "myCall(bytes8,uint256)" 0x010203040000fb2c $i --gas-limit 100000 --rpc-url $ETH_RPC_URL --json 2>&1)

  # 检查是否失败（错误信息通常会包含 "reverted" 或 "error"）
  if echo "$RESULT" | grep -qiE "error|revert"; then
    echo "❌ Gas: $i -> Failed"
    echo "   ↳ Error: $RESULT"  # 打印具体的错误信息
  else
    echo "✅ Gas: $i -> Success!"
    echo "   ↳ Response: $RESULT"  # 打印成功返回值
  fi
done
