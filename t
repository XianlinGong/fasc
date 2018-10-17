commit 052e830ebf39984d5115ca76fbe9d317eb45070c
Author: xianlingong <xianlingong@msn.com>
Date:   Wed Oct 17 09:43:26 2018 -0400

    merge nPowTargetSpacing / LWMA / gettxoutset

diff --git a/src/chainparams.cpp b/src/chainparams.cpp
index be8ffe4..4e29725 100644
--- a/src/chainparams.cpp
+++ b/src/chainparams.cpp
@@ -150,7 +150,9 @@ public:
  
         consensus.nSubsidyHalvingInterval = 3360000;
         consensus.FABHeight = 0;
-        consensus.ContractHeight = 200000;
+        consensus.ContractHeight = 250000;
+        consensus.EquihashFABHeight = 250000;
+        consensus.LWMAHeight = 250000;
         consensus.BIP16Height = 0;
         consensus.BIP34Height = 0;
         consensus.BIP34Hash = uint256S("0x0001cfb309df094182806bf71c66fd4d2d986ff2a309d211db602fc9a7db1835");
@@ -163,11 +165,17 @@ public:
         consensus.posLimit = uint256S("00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
         consensus.powLimitLegacy = uint256S("0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
 
-        consensus.nPowAveragingWindow = 17;
-        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nPowAveragingWindow);
+        //Digishield parameters
+        consensus.nDigishieldPowAveragingWindow = 17;
+        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nDigishieldPowAveragingWindow);
+        consensus.nDigishieldPowMaxAdjustDown = 32;
+        consensus.nDigishieldPowMaxAdjustUp = 16;
 
-        consensus.nPowMaxAdjustDown = 32;
-        consensus.nPowMaxAdjustUp = 16;
+        //LWMA parameters
+        consensus.nZawyLwmaAveragingWindow = 45;
+        consensus.bZawyLwmaSolvetimeLimitation = true;
+        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
+        consensus.MaxBlockInterval = 10; // 10 T
 
         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
@@ -175,8 +183,9 @@ public:
         consensus.fPowAllowMinDifficultyBlocks = false;
         consensus.fPowNoRetargeting = false;
         consensus.fPoSNoRetargeting = false;
-        consensus.nRuleChangeActivationThreshold = 1916; // 95% of 2016
-        consensus.nMinerConfirmationWindow = 2016; // nPowTargetTimespan / nPowTargetSpacing
+        consensus.nMinerConfirmationWindow = consensus.nPowTargetTimespan / consensus.nPowTargetSpacing; // 2016
+        consensus.nRuleChangeActivationThreshold = consensus.nMinerConfirmationWindow * 0.95 + 1; // 95% of 2016
+
         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].bit = 28;
         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].nStartTime = 1199145601; // January 1, 2008
         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].nTimeout = 1230767999; // December 31, 2008
@@ -239,7 +248,8 @@ public:
         base58Prefixes[EXT_SECRET_KEY] = {0x04, 0x88, 0xAD, 0xE4};
 
         fMiningRequiresPeers = true;
-        bech32_hrp = "bc";        fDefaultConsistencyChecks = false;
+        bech32_hrp = "bc";
+        fDefaultConsistencyChecks = false;
         fRequireStandard = true;
         fMineBlocksOnDemand = false;
 
@@ -278,7 +288,8 @@ public:
         consensus.nSubsidyHalvingInterval = 3360000;
         consensus.FABHeight = 0;
         consensus.ContractHeight = 192430 ;
-        consensus.BIP16Height = 0;
+        consensus.EquihashFABHeight = 221370;
+        consensus.LWMAHeight = 221370;
         consensus.BIP34Height = 0;
         consensus.BIP34Hash = uint256S("0x0001cfb309df094182806bf71c66fd4d2d986ff2a309d211db602fc9a7db1835");
         consensus.BIP65Height = 0; 
@@ -289,10 +300,18 @@ public:
         consensus.powLimit = uint256S("07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
         consensus.posLimit = uint256S("0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
         consensus.powLimitLegacy = uint256S("0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
-        consensus.nPowAveragingWindow = 17;
-        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nPowAveragingWindow);
-        consensus.nPowMaxAdjustDown = 32; // 32% adjustment down
-        consensus.nPowMaxAdjustUp = 16; // 16% adjustment up
+
+        //Digishield parameters
+        consensus.nDigishieldPowAveragingWindow = 17;
+        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nDigishieldPowAveragingWindow);
+        consensus.nDigishieldPowMaxAdjustDown = 32;
+        consensus.nDigishieldPowMaxAdjustUp = 16;
+
+        //LWMA parameters
+        consensus.nZawyLwmaAveragingWindow = 45;
+        consensus.bZawyLwmaSolvetimeLimitation = true;
+        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
+        consensus.MaxBlockInterval = 10; // 10 T
 
         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days, for SHA256 mining only
         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
@@ -403,8 +422,10 @@ public:
         consensus.BIP16Height = 0;
         consensus.BIP34Height = 0; // BIP34 has not activated on regtest (far in the future so block v1 are not rejected in tests) // activate for fabcoin
         consensus.BIP34Hash = uint256S("0x0e28ba5df35c1ac0893b7d37db241a6f4afac5498da89369067427dc369f9df3");
-        consensus.BIP65Height = 0; // BIP65 activated on regtest (Used in rpc activation tests)
-        consensus.BIP66Height = 0; // BIP66 activated on regtest (Used in rpc activation tests)
+        //consensus.BIP65Height = 0; // BIP65 activated on regtest (Used in rpc activation tests)
+        //consensus.BIP66Height = 0; // BIP66 activated on regtest (Used in rpc activation tests)
+        consensus.BIP65Height = 1351; // BIP65 activated on regtest (Used in rpc activation tests)
+        consensus.BIP66Height = 1251; // BIP66 activated on regtest (Used in rpc activation tests)
         consensus.powLimit = uint256S("7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
         consensus.posLimit = uint256S("7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
@@ -416,13 +437,21 @@ public:
 
         consensus.FABHeight = 0x7fffffff;
         consensus.ContractHeight = 100;
+        consensus.EquihashFABHeight = 0x7fffffff;
+        consensus.LWMAHeight = 0x7fffffff;
         consensus.CoinbaseLock = 0;
         consensus.ForceSegwit = false;
 
+        //Digishield parameters
+        consensus.nDigishieldPowAveragingWindow = 17;
+        consensus.nDigishieldPowMaxAdjustDown = 32;
+        consensus.nDigishieldPowMaxAdjustUp = 16;
 
-        consensus.nPowAveragingWindow = 17;
-        consensus.nPowMaxAdjustDown = 32;
-        consensus.nPowMaxAdjustUp = 16;
+        //LWMA parameters
+        consensus.nZawyLwmaAveragingWindow = 45;
+        consensus.bZawyLwmaSolvetimeLimitation = true;
+        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
+        consensus.MaxBlockInterval = 10; // 10 T
 
         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
diff --git a/src/chainparams.h b/src/chainparams.h
index 36ff57b..04df74d 100644
--- a/src/chainparams.h
+++ b/src/chainparams.h
@@ -63,9 +63,10 @@ public:
     /** Policy: Filter transactions that do not match well-defined patterns */
     bool RequireStandard() const { return fRequireStandard; }
     uint64_t PruneAfterHeight() const { return nPruneAfterHeight; }
-    unsigned int EquihashN(uint32_t nHeight = 0) const { return (nHeight < consensus.ContractHeight) || (strNetworkID != CBaseChainParams::MAIN) ? nEquihashN : 184; }
-    unsigned int EquihashK(uint32_t nHeight = 0) const { return (nHeight < consensus.ContractHeight) || (strNetworkID != CBaseChainParams::MAIN) ? nEquihashK : 7; }
-    int64_t GetnPowTargetSpacing( uint32_t nHeight = 0 ) const { return (nHeight < consensus.ContractHeight) ? consensus.nPowTargetSpacing : 2* consensus.nPowTargetSpacing; }
+    unsigned int EquihashN(uint32_t nHeight = 0) const { return (nHeight < consensus.EquihashFABHeight) /*|| (strNetworkID != CBaseChainParams::MAIN)*/ ? nEquihashN : 184; }
+    unsigned int EquihashK(uint32_t nHeight = 0) const { return (nHeight < consensus.EquihashFABHeight) /*|| (strNetworkID != CBaseChainParams::MAIN)*/ ? nEquihashK : 7; }
+    int64_t GetnPowTargetSpacing( uint32_t nHeight = 0 ) const { return (nHeight < consensus.EquihashFABHeight) ? consensus.nPowTargetSpacing : 2* consensus.nPowTargetSpacing; }
+
     /** Make miner stop after a block is found. In RPC, don't return until nGenProcLimit blocks are generated */
     bool MineBlocksOnDemand() const { return fMineBlocksOnDemand; }
     /** Return the BIP70 network string (main, test or regtest) */
diff --git a/src/consensus/params.h b/src/consensus/params.h
index 434079b..72778bb 100644
--- a/src/consensus/params.h
+++ b/src/consensus/params.h
@@ -62,8 +62,14 @@ struct Params {
     int BIP66Height;
     /** Block height at which Fabcoin Equihash hard fork becomes active */
     uint32_t FABHeight;
+    /** Block height at which LWMA becomes active */
+    uint32_t LWMAHeight;
     /** Block height at which Fabcoin Smart Contract hard fork becomes active */
     uint32_t ContractHeight;
+    /** Block height at which EquihashFAB (184,7) becomes active */
+    uint32_t EquihashFABHeight;
+    /** Limit BITCOIN_MAX_FUTURE_BLOCK_TIME **/
+    int64_t MaxFutureBlockTime;
     /** Block height before which the coinbase subsidy will be locked for the same period */
     int CoinbaseLock;
     /** whether segwit is active */
@@ -87,7 +93,7 @@ struct Params {
     bool fPoSNoRetargeting;
     int64_t nPowTargetSpacing;
     int64_t nPowTargetTimespan;
-    int64_t DifficultyAdjustmentInterval() const { return nPowTargetTimespan / nPowTargetSpacing; }
+    int64_t DifficultyAdjustmentInterval(uint32_t nheight=0) const { return nPowTargetTimespan / (nheight < EquihashFABHeight ? nPowTargetSpacing : 2*nPowTargetSpacing); }
     uint256 nMinimumChainWork;
     uint256 defaultAssumeValid;
     int nLastPOWBlock;
@@ -95,13 +101,19 @@ struct Params {
     int nMPoSRewardRecipients;
     int nFixUTXOCacheHFHeight;
 
-    //Zcash logic for diff adjustment
-    int64_t nPowAveragingWindow;
-    int64_t nPowMaxAdjustDown;
-    int64_t nPowMaxAdjustUp;
-    int64_t AveragingWindowTimespan() const { return nPowAveragingWindow * nPowTargetSpacing; }
-    int64_t MinActualTimespan() const { return (AveragingWindowTimespan() * (100 - nPowMaxAdjustUp  )) / 100; }
-    int64_t MaxActualTimespan() const { return (AveragingWindowTimespan() * (100 + nPowMaxAdjustDown)) / 100; }
+    // Params for Zawy's LWMA difficulty adjustment algorithm.
+    int64_t nZawyLwmaAveragingWindow;
+    bool bZawyLwmaSolvetimeLimitation;
+    uint8_t MaxBlockInterval;
+
+    //Digishield logic for difficulty adjustment
+    int64_t nDigishieldPowAveragingWindow;
+    int64_t nDigishieldPowMaxAdjustDown;
+    int64_t nDigishieldPowMaxAdjustUp;
+
+    int64_t DigishieldAveragingWindowTimespan(uint32_t nheight=0) const { return nDigishieldPowAveragingWindow * (nheight < EquihashFABHeight ? nPowTargetSpacing : 2*nPowTargetSpacing); }
+    int64_t DigishieldMinActualTimespan(uint32_t nheight=0) const { return (DigishieldAveragingWindowTimespan(nheight) * (100 - nDigishieldPowMaxAdjustUp  )) / 100; }
+    int64_t DigishieldMaxActualTimespan(uint32_t nheight=0) const { return (DigishieldAveragingWindowTimespan(nheight) * (100 + nDigishieldPowMaxAdjustDown)) / 100; }
 };
 } // namespace Consensus
 
diff --git a/src/miner.cpp b/src/miner.cpp
index ff7cd15..f550a62 100644
--- a/src/miner.cpp
+++ b/src/miner.cpp
@@ -79,6 +79,15 @@ int64_t UpdateTime(CBlockHeader* pblock, const Consensus::Params& consensusParam
     return nNewTime - nOldTime;
 }
 
+bool IsBlockTooLate(CBlockHeader* pblock, const Consensus::Params& consensusParams, const CBlockIndex* pindexPrev)
+{
+    if( GetAdjustedTime() > std::max(pblock->GetBlockTime(), pindexPrev->GetBlockTime()) + Params().GetnPowTargetSpacing(pindexPrev->nHeight+1) * consensusParams.MaxBlockInterval ) 
+    {
+        return true;
+    }
+    return false;
+}
+
 BlockAssembler::Options::Options() {
     blockMinFeeRate = CFeeRate(DEFAULT_BLOCK_MIN_TX_FEE);
     nBlockMaxWeight = DEFAULT_BLOCK_MAX_WEIGHT;
@@ -285,7 +294,7 @@ std::unique_ptr<CBlockTemplate> BlockAssembler::CreateNewBlock(const CScript& sc
     pblock->hashPrevBlock  = pindexPrev->GetBlockHash();
     pblock->nHeight        = pindexPrev->nHeight + 1;
     memset(pblock->nReserved, 0, sizeof(pblock->nReserved));
-
+    pblock->nBits = GetNextWorkRequired(pindexPrev, pblock, chainparams.GetConsensus(),fProofOfStake);
 
     arith_uint256 nonce;
     if ((uint32_t)nHeight >= (uint32_t)chainparams.GetConsensus().FABHeight) {
@@ -1191,8 +1200,8 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
             n = chainparams.EquihashN(pblock->nHeight);
             k = chainparams.EquihashK(pblock->nHeight);
 
-            LogPrintf("FabcoinMiner mining   with %u transactions in block (%u bytes) @(%s)  \n", pblock->vtx.size(),
-                ::GetSerializeSize(*pblock, SER_NETWORK, PROTOCOL_VERSION), conf.useGPU?"GPU":"CPU" );
+            LogPrintf("FabcoinMiner mining   with %u transactions in block (%u bytes) @(%s)  n=%d, k=%d\n", pblock->vtx.size(),
+                ::GetSerializeSize(*pblock, SER_NETWORK, PROTOCOL_VERSION), conf.useGPU?"GPU":"CPU", n, k );
 
             headerlen = (pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight) ? CBlockHeader::HEADER_SIZE : CBlockHeader::HEADER_NEWSIZE;
             //
@@ -1204,9 +1213,9 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
 
             nCounter = 0;
             if (conf.useGPU)
-                LogPrint(BCLog::POW, "Equihash solver (%d,%d) in GPU (%u, %u) with nNonce = %s hashTarget=%s\n", n, k, conf.currentPlatform, conf.currentDevice, pblock->nNonce.ToString(), hashTarget.GetHex());
+                LogPrint(BCLog::POW, "Equihash solver in GPU (%u, %u) with nNonce = %s hashTarget=%s\n", conf.currentPlatform, conf.currentDevice, pblock->nNonce.ToString(), hashTarget.GetHex());
             else 
-                LogPrint(BCLog::POW, "Equihash solver (%d,%d) in CPU with nNonce = %s hashTarget=%s\n", n, k, pblock->nNonce.ToString(), hashTarget.GetHex());
+                LogPrint(BCLog::POW, "Equihash solver in CPU with nNonce = %s hashTarget=%s\n", pblock->nNonce.ToString(), hashTarget.GetHex());
   
             double secs, solps;
             g_nSols[thr_id] = 0;
@@ -1350,6 +1359,17 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
                 //    break; // Recreate the block if the clock has run backwards,
 
                 // so that we can use the correct time.
+
+
+                if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
+                {
+                    // check if the new block will come too late. If so, create the block again to change block time
+                    if( IsBlockTooLate( pblock, chainparams.GetConsensus(), pindexPrev ) )
+                    {
+                        break;
+                    }
+                }
+
                 if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
                 {
                     // Changing pblock->nTime can change work required on testnet:
@@ -1500,7 +1520,7 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
 
             try
             {
-                if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight)   // before fork
+                if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().EquihashFABHeight)   // before fork
                 {
                     if( g_solver184_7 ) 
                     {
@@ -1562,7 +1582,7 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
                 try {
                     bool found = false;
 
-                    if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight )   // before fork
+                    if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().EquihashFABHeight )   // before fork
                     {
                         if( g_solver )
                             found = g_solver->solve((unsigned char *)pblock, header, headerlen);
@@ -1602,6 +1622,17 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
                 //if (UpdateTime(pblock, chainparams.GetConsensus(), pindexPrev) < 0)
                 //    break; // Recreate the block if the clock has run backwards,
                 // so that we can use the correct time.
+
+
+                if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
+                {
+                    // check if the new block will come too late. If so, create the block again to change block time
+                    if( IsBlockTooLate( pblock, chainparams.GetConsensus(), pindexPrev ) )
+                    {
+                        break;
+                    }
+                }
+
                 if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
                 {
                     // Changing pblock->nTime can change work required on testnet:
@@ -1733,15 +1764,29 @@ void GenerateFabcoins(bool fGenerate, int nThreads, const CChainParams& chainpar
                     devices[device].getInfo(CL_DEVICE_GLOBAL_MEM_SIZE, &result);
 
                     int maxThreads = nThreads;
+                    CBlockIndex* pindexPrev = chainActive.Tip();
+
                     if (!conf.forceGenProcLimit) {
-                        if (result > 7500000000) {
-                            maxThreads = std::min(4, nThreads);
-                        } else if (result > 5500000000) {
-                            maxThreads = std::min(3, nThreads);
-                        } else if (result > 3500000000) {
-                            maxThreads = std::min(2, nThreads);
-                        } else {
-                            maxThreads = std::min(1, nThreads);
+
+                        if( (pindexPrev->nHeight+1) < chainparams.GetConsensus().EquihashFABHeight )
+                        {
+                            if (result > 7500000000) {
+                                maxThreads = std::min(4, nThreads);
+                            } else if (result > 5500000000) {
+                                maxThreads = std::min(3, nThreads);
+                            } else if (result > 3500000000) {
+                                maxThreads = std::min(2, nThreads);
+                            } else {
+                                maxThreads = std::min(1, nThreads);
+                            }
+                        }
+                        else
+                        {
+                            if (result > 7500000000) {
+                                maxThreads = std::min(2, nThreads);
+                            } else {
+                                maxThreads = std::min(1, nThreads);
+                            }
                         }
                     }
 
diff --git a/src/net_processing.cpp b/src/net_processing.cpp
index b1bdfe2..e6ca3e3 100644
--- a/src/net_processing.cpp
+++ b/src/net_processing.cpp
@@ -454,13 +454,13 @@ bool TipMayBeStale(const Consensus::Params &consensusParams)
     if (g_last_tip_update == 0) {
         g_last_tip_update = GetTime();
     }
-    return g_last_tip_update < GetTime() - consensusParams.nPowTargetSpacing * 3 && mapBlocksInFlight.empty();
+    return g_last_tip_update < GetTime() - Params().GetnPowTargetSpacing(chainActive.Height())* 3 && mapBlocksInFlight.empty();
 }
 
 // Requires cs_main
 bool CanDirectFetch(const Consensus::Params &consensusParams)
 {
-    return chainActive.Tip()->GetBlockTime() > GetAdjustedTime() - consensusParams.nPowTargetSpacing * 20;
+    return chainActive.Tip()->GetBlockTime() > GetAdjustedTime() - Params().GetnPowTargetSpacing (chainActive.Height()) * 20;
 }
 
 // Requires cs_main
@@ -1991,7 +1991,8 @@ bool static ProcessMessage(CNode* pfrom, const std::string& strCommand, CDataStr
             }
             // If pruning, don't inv blocks unless we have on disk and are likely to still have
             // for some reasonable time window (1 hour) that block relay might require.
-            const int nPrunedBlocksLikelyToHave = MIN_BLOCKS_TO_KEEP - 3600 / chainparams.GetConsensus().nPowTargetSpacing;
+            const int nPrunedBlocksLikelyToHave = MIN_BLOCKS_TO_KEEP - 3600 / chainparams.GetnPowTargetSpacing(chainActive.Height()) ;
+
             if (fPruneMode && (!(pindex->nStatus & BLOCK_HAVE_DATA) || pindex->nHeight <= chainActive.Tip()->nHeight - nPrunedBlocksLikelyToHave))
             {
                 LogPrint(BCLog::NET, " getblocks stopping, pruned or too old block at %d %s\n", pindex->nHeight, pindex->GetBlockHash().ToString());
@@ -3273,7 +3274,8 @@ bool PeerLogicValidation::SendMessages(CNode* pto, std::atomic<bool>& interruptM
             // Only actively request headers from a single peer, unless we're close to today.
             if ((nSyncStarted == 0 && fFetch) || pindexBestHeader->GetBlockTime() > GetAdjustedTime() - 24 * 60 * 60) {
                 state.fSyncStarted = true;
-                state.nHeadersSyncTimeout = GetTimeMicros() + HEADERS_DOWNLOAD_TIMEOUT_BASE + HEADERS_DOWNLOAD_TIMEOUT_PER_HEADER * (GetAdjustedTime() - pindexBestHeader->GetBlockTime())/(consensusParams.nPowTargetSpacing);
+                state.nHeadersSyncTimeout = GetTimeMicros() + HEADERS_DOWNLOAD_TIMEOUT_BASE + HEADERS_DOWNLOAD_TIMEOUT_PER_HEADER * (GetAdjustedTime() - pindexBestHeader->GetBlockTime())/(Params().GetnPowTargetSpacing(pindexBestHeader->nHeight ));
+
                 nSyncStarted++;
                 const CBlockIndex *pindexStart = pindexBestHeader;
                 /* If possible, start at the block preceding the currently
@@ -3591,7 +3593,7 @@ bool PeerLogicValidation::SendMessages(CNode* pto, std::atomic<bool>& interruptM
         if (state.vBlocksInFlight.size() > 0) {
             QueuedBlock &queuedBlock = state.vBlocksInFlight.front();
             int nOtherPeersWithValidatedDownloads = nPeersWithValidatedDownloads - (state.nBlocksInFlightValidHeaders > 0);
-            if (nNow > state.nDownloadingSince + consensusParams.nPowTargetSpacing * (BLOCK_DOWNLOAD_TIMEOUT_BASE + BLOCK_DOWNLOAD_TIMEOUT_PER_PEER * nOtherPeersWithValidatedDownloads)) {
+            if ( nNow > state.nDownloadingSince + Params().GetnPowTargetSpacing(chainActive.Height()) * (BLOCK_DOWNLOAD_TIMEOUT_BASE + BLOCK_DOWNLOAD_TIMEOUT_PER_PEER * nOtherPeersWithValidatedDownloads)) {
                 LogPrintf("Timeout downloading block %s from peer=%d, disconnecting\n", queuedBlock.hash.ToString(), pto->GetId());
                 pto->fDisconnect = true;
                 return true;
diff --git a/src/pow.cpp b/src/pow.cpp
index 440db9b..363193e 100644
--- a/src/pow.cpp
+++ b/src/pow.cpp
@@ -45,18 +45,179 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
     if (pindexLast == NULL)
         return nTargetLimit;
 
+    if (params.fPowNoRetargeting)
+        return pindexLast->nBits;
+
     // first block
     const CBlockIndex* pindexPrev = GetLastBlockIndex(pindexLast, fProofOfStake);
     if (pindexPrev->pprev == NULL)
         return nTargetLimit;
 
+    uint32_t nHeight = pindexPrev->nHeight + 1;
+
+    if (nHeight < params.LWMAHeight)
+    {
+        // Digishield v3.
+        return DigishieldGetNextWorkRequired(pindexPrev, pblock, params);
+    } 
+    else if (nHeight < params.LWMAHeight + params.nZawyLwmaAveragingWindow && params.LWMAHeight == params.EquihashFABHeight ) 
+    {
+        // Reduce the difficulty of the first forked block by 100x and keep it for N blocks.
+        if (nHeight == params.LWMAHeight)
+        {
+            return ReduceDifficultyBy(pindexPrev, 100, params);
+        }
+        else
+        {
+            return pindexPrev->nBits;
+        }
+    }
+    else
+    {
+        // Zawy's LWMA.
+        return LwmaGetNextWorkRequired(pindexPrev, pblock, params);
+    }
+}
+
+unsigned int LwmaGetNextWorkRequired(const CBlockIndex* pindexPrev, const CBlockHeader *pblock, const Consensus::Params& params)
+{
+    // If the new block's timestamp is more than 10 * T minutes
+    // then halve the difficulty
+    int64_t diff = pblock->GetBlockTime() - pindexPrev->GetBlockTime();
+    if ( params.fPowAllowMinDifficultyBlocks && diff > ( pindexPrev->nHeight+1 < params.EquihashFABHeight ? params.nPowTargetSpacing : 2*params.nPowTargetSpacing ) * params.MaxBlockInterval ) 
+    {
+#if 1
+        LogPrintf("The new block(height=%d) will come too late. Use minimum difficulty.\n", pblock->nHeight);
+        return UintToArith256(params.PowLimit(true)).GetCompact();
+#else
+        arith_uint256 target;
+        target.SetCompact(pindexPrev->nBits);
+        int n = diff / ( pindexPrev->nHeight+1<params.EquihashFABHeight:params.nPowTargetSpacing:2*params.nPowTargetSpacing ) * params.MaxBlockInterval);
+
+        while( n-- > 0 )
+        {
+            target <<= 1;
+        }
+
+        const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
+        if (target > pow_limit) {
+            target = pow_limit;
+        }
+
+        LogPrintf("The new block(height=%d) will come too late. Halve the difficulty to %x.\n", pblock->nHeight, target.GetCompact());
+        return target.GetCompact();
+#endif
+    }
+    return LwmaCalculateNextWorkRequired(pindexPrev, params);
+}
+
+unsigned int LwmaCalculateNextWorkRequired(const CBlockIndex* pindexPrev, const Consensus::Params& params)
+{
     if (params.fPowNoRetargeting)
-        return pindexLast->nBits;
+    {
+        return pindexPrev->nBits;
+    }
+
+    const int height = pindexPrev->nHeight + 1;
+
+    const int64_t T = height < params.EquihashFABHeight ? params.nPowTargetSpacing : 2*params.nPowTargetSpacing;
+    const int N = params.nZawyLwmaAveragingWindow;
+    const int k = (N+1)/2 * 0.998 * T;  // ( (N+1)/2 * adjust * T )
+
+    assert(height > N);
+
+    arith_uint256 sum_target, sum_last10_target,sum_last5_target;;
+    int sum_time = 0, nWeight = 0;
+
+    int sum_last10_time=0;  //Solving time of the last ten block
+    int sum_last5_time=0;
+
+    // Loop through N most recent blocks.
+    for (int i = height - N; i < height; i++) {
+        const CBlockIndex* block = pindexPrev->GetAncestor(i);
+        const CBlockIndex* block_Prev = block->GetAncestor(i - 1);
+        int64_t solvetime = block->GetBlockTime() - block_Prev->GetBlockTime();
+
+        if (params.bZawyLwmaSolvetimeLimitation && solvetime > 6 * T) {
+            solvetime = 6 * T;
+        }
+
+        nWeight++;
+        sum_time += solvetime * nWeight;  // Weighted solvetime sum.
+
+        // Target sum divided by a factor, (k N^2).
+        // The factor is a part of the final equation. However we divide sum_target here to avoid
+        // potential overflow.
+        arith_uint256 target;
+        target.SetCompact(block->nBits);
+        sum_target += target / (k * N * N);
+
+        if(i >= height-10)
+        {
+            sum_last10_time += solvetime;
+            sum_last10_target += target;
+            if(i >= height-5)
+            {
+                sum_last5_time += solvetime;
+                sum_last5_target += target;
+            }
+        }
+    }
+
+    // Keep sum_time reasonable in case strange solvetimes occurred.
+    if (sum_time < N * k / 10) {
+        sum_time = N * k / 10;
+    }
+
+    const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
+    arith_uint256 next_target = sum_time * sum_target;
+
+#if 1
+    /*if the last 10 blocks are generated in 5 minutes, we tripple the difficulty of average of the last 10 blocks*/
+    if( sum_last5_time <= T )
+    {
+        arith_uint256 avg_last5_target;
+        avg_last5_target = sum_last5_target/5;
+        if(next_target > avg_last5_target/4)  next_target = avg_last5_target/4;
+    }
+    else if(sum_last10_time <= 2 * T)
+    {
+        arith_uint256 avg_last10_target;
+        avg_last10_target = sum_last10_target/10;
+        if(next_target > avg_last10_target/3)  next_target = avg_last10_target/3;
+    }
+    else if(sum_last10_time <= 5 * T)
+    {
+        arith_uint256 avg_last10_target;
+        avg_last10_target = sum_last10_target/10;
+        if(next_target > avg_last10_target*2/3)  next_target = avg_last10_target*2/3;
+    }
+
+    arith_uint256 last_target;
+    last_target.SetCompact(pindexPrev->nBits);
+    if( next_target > last_target * 13/10 ) next_target = last_target * 13/10;
+    /*in case difficulty drops too soon compared to the last block, especially
+     *when the effect of the last rule wears off in the new block
+     *DAA will switch to normal LWMA and cause dramatically diff drops*/
+#endif
+
+    if (next_target > pow_limit) {
+        next_target = pow_limit;
+    }
+
+    return next_target.GetCompact();
+}
+
+unsigned int DigishieldGetNextWorkRequired(const CBlockIndex* pindexPrev, const CBlockHeader *pblock,
+                                           const Consensus::Params& params)
+{
+    assert(pindexPrev != nullptr);
+    unsigned int nProofOfWorkLimit = UintToArith256(params.PowLimit(true)).GetCompact();
 
     // Find the first block in the averaging interval
-    const CBlockIndex* pindexFirst = pindexLast;
+    const CBlockIndex* pindexFirst = pindexPrev;
     arith_uint256 bnTot {0};
-    for (int i = 0; pindexFirst && i < params.nPowAveragingWindow; i++) {
+    for (int i = 0; pindexFirst && i < params.nDigishieldPowAveragingWindow; i++) {
         arith_uint256 bnTmp;
         bnTmp.SetCompact(pindexFirst->nBits);
         bnTot += bnTmp;
@@ -65,28 +226,29 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
 
     // Check we have enough blocks
     if (pindexFirst == NULL)
-        return nTargetLimit;
+        return nProofOfWorkLimit;
 
-    arith_uint256 bnAvg {bnTot / params.nPowAveragingWindow};
-
-    return CalculateNextWorkRequired(bnAvg, pindexLast->GetMedianTimePast(), pindexFirst->GetMedianTimePast(), params );
+    arith_uint256 bnAvg {bnTot / params.nDigishieldPowAveragingWindow};
+    return DigishieldCalculateNextWorkRequired(pindexPrev, bnAvg, pindexPrev->GetMedianTimePast(), pindexFirst->GetMedianTimePast(), params);
 }
-unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params)
+
+
+unsigned int DigishieldCalculateNextWorkRequired(const CBlockIndex* pindexPrev, arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params)
 {
     // Limit adjustment
     // Use medians to prevent time-warp attacks
     int64_t nActualTimespan = nLastBlockTime - nFirstBlockTime;
-    nActualTimespan = params.AveragingWindowTimespan() + (nActualTimespan - params.AveragingWindowTimespan())/4;
+    nActualTimespan = params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight) + (nActualTimespan - params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight))/4;
 
-    if (nActualTimespan < params.MinActualTimespan())
-        nActualTimespan = params.MinActualTimespan();
-    if (nActualTimespan > params.MaxActualTimespan())
-        nActualTimespan = params.MaxActualTimespan();
+    if (nActualTimespan < params.DigishieldMinActualTimespan(pindexPrev->nHeight))
+        nActualTimespan = params.DigishieldMinActualTimespan(pindexPrev->nHeight);
+    if (nActualTimespan > params.DigishieldMaxActualTimespan(pindexPrev->nHeight))
+        nActualTimespan = params.DigishieldMaxActualTimespan(pindexPrev->nHeight);
 
     // Retarget
-    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
+    const arith_uint256 bnPowLimit = UintToArith256(params.PowLimit(true));
     arith_uint256 bnNew {bnAvg};
-    bnNew /= params.AveragingWindowTimespan();
+    bnNew /= params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight);
     bnNew *= nActualTimespan;
 
     if (bnNew > bnPowLimit)
@@ -95,6 +257,22 @@ unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTi
     return bnNew.GetCompact();
 }
 
+unsigned int ReduceDifficultyBy(const CBlockIndex* pindexPrev, int64_t multiplier, const Consensus::Params& params)
+{
+    arith_uint256 target;
+
+    target.SetCompact(pindexPrev->nBits);
+    target *= multiplier;
+
+    const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
+    if (target > pow_limit)
+    {
+        target = pow_limit;
+    }
+    return target.GetCompact();
+}
+
+
 bool CheckEquihashSolution(const CBlockHeader *pblock, const CChainParams& params)
 {
 
diff --git a/src/pow.h b/src/pow.h
index 76ae7ed..1bbc861 100644
--- a/src/pow.h
+++ b/src/pow.h
@@ -20,6 +20,17 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
 //unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast, int64_t nFirstBlockTime, const Consensus::Params&);
 unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params);
 
+/** Zawy's LWMA - next generation algorithm  */
+unsigned int LwmaGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params&);
+
+unsigned int LwmaCalculateNextWorkRequired(const CBlockIndex* pindexLast, const Consensus::Params& params);
+
+/** Digishield v3 - used in Fabcoin mainnet currently */
+unsigned int DigishieldGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params&);
+unsigned int DigishieldCalculateNextWorkRequired(const CBlockIndex* pindexLast, arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params);
+
+/** Reduce the difficulty by a given multiplier. It doesn't check uint256 overflow! */
+unsigned int ReduceDifficultyBy(const CBlockIndex* pindexLast, int64_t multiplier, const Consensus::Params& params);
 
 /** Check whether the Equihash solution in a block header is valid */
 bool CheckEquihashSolution(const CBlockHeader *pblock, const CChainParams&);
diff --git a/src/qt/fabcoingui.cpp b/src/qt/fabcoingui.cpp
index dcd5cf6..ed7b8cc 100644
--- a/src/qt/fabcoingui.cpp
+++ b/src/qt/fabcoingui.cpp
@@ -926,7 +926,8 @@ void FabcoinGUI::updateHeadersSyncProgressLabel()
 {
     int64_t headersTipTime = clientModel->getHeaderTipTime();
     int headersTipHeight = clientModel->getHeaderTipHeight();
-    int estHeadersLeft = (GetTime() - headersTipTime) / Params().GetConsensus().nPowTargetSpacing;
+    int estHeadersLeft = (GetTime() - headersTipTime) / Params().GetnPowTargetSpacing(headersTipHeight);
+
     if (estHeadersLeft > HEADER_HEIGHT_DELTA_SYNC)
         progressBarLabel->setText(tr("Syncing Headers (%1%)...").arg(QString::number(100.0 / (headersTipHeight+estHeadersLeft)*headersTipHeight, 'f', 1)));
 }
@@ -1349,7 +1350,9 @@ void FabcoinGUI::updateStakingIcon()
         uint64_t nWeight = this->nWeight;
         uint64_t nNetworkWeight = GetPoSKernelPS();
         const Consensus::Params& consensusParams = Params().GetConsensus();
-        int64_t nTargetSpacing = consensusParams.nPowTargetSpacing;
+
+        int headersTipHeight = clientModel->getHeaderTipHeight();
+        int64_t nTargetSpacing = Params().GetnPowTargetSpacing(headersTipHeight);
 
         unsigned nEstimateTime = nTargetSpacing * nNetworkWeight / nWeight;
 
diff --git a/src/qt/modaloverlay.cpp b/src/qt/modaloverlay.cpp
index b000df7..1c8d507 100644
--- a/src/qt/modaloverlay.cpp
+++ b/src/qt/modaloverlay.cpp
@@ -139,7 +139,8 @@ void ModalOverlay::tipUpdate(int count, const QDateTime& blockDate, double nVeri
 
     // estimate the number of headers left based on nPowTargetSpacing
     // and check if the gui is not aware of the best header (happens rarely)
-    int estimateNumHeadersLeft = bestHeaderDate.secsTo(currentDate) / Params().GetConsensus().nPowTargetSpacing;
+     
+    int estimateNumHeadersLeft = bestHeaderDate.secsTo(currentDate) / Params().GetnPowTargetSpacing(bestHeaderHeight);
     bool hasBestHeader = bestHeaderHeight >= count;
 
     // show remaining number of blocks
diff --git a/src/qt/sendcoinsdialog.cpp b/src/qt/sendcoinsdialog.cpp
index e548265..4ee64bc 100644
--- a/src/qt/sendcoinsdialog.cpp
+++ b/src/qt/sendcoinsdialog.cpp
@@ -164,7 +164,9 @@ void SendCoinsDialog::setModel(WalletModel *_model)
         coinControlUpdateLabels();
 
         // fee section
+        //int headersTipHeight = clientModel->getHeaderTipHeight();
         for (const int n : confTargets) {
+            //ui->confTargetSelector->addItem(tr("%1 (%2 blocks)").arg(GUIUtil::formatNiceTimeOffset(n*Params().GetnPowTargetSpacing(headersTipHeight))).arg(n));
             ui->confTargetSelector->addItem(tr("%1 (%2 blocks)").arg(GUIUtil::formatNiceTimeOffset(n*Params().GetConsensus().nPowTargetSpacing)).arg(n));
         }
         connect(ui->confTargetSelector, SIGNAL(currentIndexChanged(int)), this, SLOT(updateSmartFeeLabel()));
diff --git a/src/rpc/blockchain.cpp b/src/rpc/blockchain.cpp
index 904999f..7acce36 100644
--- a/src/rpc/blockchain.cpp
+++ b/src/rpc/blockchain.cpp
@@ -1915,7 +1915,7 @@ UniValue gettxoutset(const JSONRPCRequest& request)
         + HelpExampleRpc("gettxoutset", "")
         );
 
-    UniValue ret(UniValue::VOBJ);
+    UniValue ret(UniValue::VARR);
 
     CCoinsStats stats;
     FlushStateToDisk();
@@ -1943,9 +1943,10 @@ UniValue gettxoutset(const JSONRPCRequest& request)
             {
                 for( const CTxDestination addr: addresses )
                 {
-                    strUtxo << coin.nHeight << ", " << key.hash.ToString() << ", " << key.n << ", " << EncodeDestination(addr) << ", " << coin.out.nValue  << ", " << coin.fCoinBase;
+                    //strUtxo << coin.nHeight << ", " << CFabcoinAddress(addr).ToString() << ", " << coin.out.nValue ;
 
-                    ret.push_back(Pair("UTXO", strUtxo.str()));
+                    strUtxo << coin.nHeight << ", " << key.hash.ToString() << ", " << key.n << ", " << CFabcoinAddress(addr).ToString() << ", " << coin.out.nValue ;
+                    ret.push_back(strUtxo.str());
                 }
             }
             else
@@ -2541,7 +2542,8 @@ UniValue getchaintxstats(const JSONRPCRequest& request)
         );
 
     const CBlockIndex* pindex;
-    int blockcount = 30 * 24 * 60 * 60 / Params().GetConsensus().nPowTargetSpacing; // By default: 1 month
+
+    int blockcount = 30 * 24 * 60 * 60 / Params().GetnPowTargetSpacing(chainActive.Height()); // By default: 1 month
 
     bool havehash = !request.params[1].isNull();
     uint256 hash;
diff --git a/src/rpc/mining.cpp b/src/rpc/mining.cpp
index 39afd12..ea674cb 100644
--- a/src/rpc/mining.cpp
+++ b/src/rpc/mining.cpp
@@ -486,7 +486,7 @@ UniValue getstakinginfo(const JSONRPCRequest& request)
     uint64_t nNetworkWeight = GetPoSKernelPS();
     bool staking = nLastCoinStakeSearchInterval && nWeight;
     const Consensus::Params& consensusParams = Params().GetConsensus();
-    int64_t nTargetSpacing = consensusParams.nPowTargetSpacing;
+    int64_t nTargetSpacing = Params().GetnPowTargetSpacing(chainActive.Height());
     uint64_t nExpectedTime = staking ? (nTargetSpacing * nNetworkWeight / nWeight) : 0;
 
     UniValue obj(UniValue::VOBJ);
diff --git a/src/t b/src/t
new file mode 100644
index 0000000..fd2f51d
--- /dev/null
+++ b/src/t
@@ -0,0 +1,972 @@
+diff --git a/.gitignore b/.gitignore
+index ae88952..608741c 100644
+--- a/.gitignore
++++ b/.gitignore
+@@ -1,13 +1,30 @@
+ *.tar.gz
+ 
++.vs/
++.vscode/
++
++test/config.ini
++test/fasc/tmp*.sr
++test/fasc02/tmp*.sr
++
++
++src/cpp-ethereum/deps/src/cryptopp-stamp/download-cryptopp.cmake
++src/cpp-ethereum/deps/src/cryptopp-stamp/extract-cryptopp.cmake
++src/cpp-ethereum/deps/src/jsoncpp-stamp/download-jsoncpp.cmake
++src/cpp-ethereum/deps/src/jsoncpp-stamp/extract-jsoncpp.cmake
++src/cpp-ethereum/deps/src/secp256k1-stamp/download-secp256k1.cmake
++src/cpp-ethereum/deps/src/secp256k1-stamp/extract-secp256k1.cmake
++src/cpp-ethereum/deps/tmp/cryptopp-cfgcmd.txt
++src/cpp-ethereum/deps/tmp/jsoncpp-cfgcmd.txt
++
+ *.exe
+-src/bitcoin
+-src/bitcoind
+-src/bitcoin-cli
+-src/bitcoin-tx
+-src/test/test_bitcoin
+-src/test/test_bitcoin_fuzzy
+-src/qt/test/test_bitcoin-qt
++src/fabcoin
++src/fabcoind
++src/fabcoin-cli
++src/fabcoin-tx
++src/test/test_fabcoin
++src/qt/test/test_fabcoin-qt
++src/test/test_fabcoin_fuzzy
+ 
+ # autoreconf
+ Makefile.in
+@@ -30,8 +47,8 @@ config.log
+ config.status
+ configure
+ libtool
+-src/config/bitcoin-config.h
+-src/config/bitcoin-config.h.in
++src/config/fabcoin-config.h
++src/config/fabcoin-config.h.in
+ src/config/stamp-h1
+ share/setup.nsi
+ share/qt/Info.plist
+@@ -44,12 +61,6 @@ src/qt/forms/ui_*.h
+ 
+ src/qt/test/moc*.cpp
+ 
+-src/qt/bitcoin-qt.config
+-src/qt/bitcoin-qt.creator
+-src/qt/bitcoin-qt.creator.user
+-src/qt/bitcoin-qt.files
+-src/qt/bitcoin-qt.includes
+-
+ .deps
+ .dirstamp
+ .libs
+@@ -62,6 +73,7 @@ src/qt/bitcoin-qt.includes
+ *.o
+ *.o-*
+ *.patch
++.fabcoin
+ *.a
+ *.pb.cc
+ *.pb.h
+@@ -80,13 +92,13 @@ src/qt/bitcoin-qt.includes
+ # Compilation and Qt preprocessor part
+ *.qm
+ Makefile
+-bitcoin-qt
+-Bitcoin-Qt.app
+-background.tiff*
++fabcoin-qt
++Fabcoin-Qt.app
+ 
+ # Unit-tests
+ Makefile.test
+-bitcoin-qt_test
++fabcoin-qt_test
++src/test/buildenv.py
+ 
+ # Resources cpp
+ qrc_*.cpp
+@@ -99,7 +111,7 @@ build
+ *.gcno
+ *.gcda
+ /*.info
+-test_bitcoin.coverage/
++test_fabcoin.coverage/
+ total.coverage/
+ coverage_percent.txt
+ 
+@@ -107,24 +119,17 @@ coverage_percent.txt
+ linux-coverage-build
+ linux-build
+ win32-build
+-test/config.ini
+-test/cache/*
++qa/pull-tester/run-fabcoind-for-test.sh
++qa/pull-tester/tests_config.py
++qa/pull-tester/cache/*
++qa/pull-tester/test.*/*
++qa/tmp
++cache/
++share/FabcoindComparisonTool.jar
+ 
+ !src/leveldb*/Makefile
+ 
+ /doc/doxygen/
+ 
+-libbitcoinconsensus.pc
++libfabcoinconsensus.pc
+ contrib/devtools/split-debug.sh
+-.cproject
+-.project
+-.settings/language.settings.xml
+-src/qtum-cli
+-src/qtum-tx
+-src/qtumd
+-src/bench/bench_qtum
+-src/qt/qtum-qt
+-src/qt/test/test_qtum-qt
+-src/test/buildenv.py
+-src/test/test_qtum
+-src/test/test_qtum_fuzzy
+diff --git a/src/chainparams.cpp b/src/chainparams.cpp
+index be8ffe4..4e29725 100644
+--- a/src/chainparams.cpp
++++ b/src/chainparams.cpp
+@@ -150,7 +150,9 @@ public:
+  
+         consensus.nSubsidyHalvingInterval = 3360000;
+         consensus.FABHeight = 0;
+-        consensus.ContractHeight = 200000;
++        consensus.ContractHeight = 250000;
++        consensus.EquihashFABHeight = 250000;
++        consensus.LWMAHeight = 250000;
+         consensus.BIP16Height = 0;
+         consensus.BIP34Height = 0;
+         consensus.BIP34Hash = uint256S("0x0001cfb309df094182806bf71c66fd4d2d986ff2a309d211db602fc9a7db1835");
+@@ -163,11 +165,17 @@ public:
+         consensus.posLimit = uint256S("00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+         consensus.powLimitLegacy = uint256S("0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+ 
+-        consensus.nPowAveragingWindow = 17;
+-        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nPowAveragingWindow);
++        //Digishield parameters
++        consensus.nDigishieldPowAveragingWindow = 17;
++        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nDigishieldPowAveragingWindow);
++        consensus.nDigishieldPowMaxAdjustDown = 32;
++        consensus.nDigishieldPowMaxAdjustUp = 16;
+ 
+-        consensus.nPowMaxAdjustDown = 32;
+-        consensus.nPowMaxAdjustUp = 16;
++        //LWMA parameters
++        consensus.nZawyLwmaAveragingWindow = 45;
++        consensus.bZawyLwmaSolvetimeLimitation = true;
++        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
++        consensus.MaxBlockInterval = 10; // 10 T
+ 
+         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
+         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
+@@ -175,8 +183,9 @@ public:
+         consensus.fPowAllowMinDifficultyBlocks = false;
+         consensus.fPowNoRetargeting = false;
+         consensus.fPoSNoRetargeting = false;
+-        consensus.nRuleChangeActivationThreshold = 1916; // 95% of 2016
+-        consensus.nMinerConfirmationWindow = 2016; // nPowTargetTimespan / nPowTargetSpacing
++        consensus.nMinerConfirmationWindow = consensus.nPowTargetTimespan / consensus.nPowTargetSpacing; // 2016
++        consensus.nRuleChangeActivationThreshold = consensus.nMinerConfirmationWindow * 0.95 + 1; // 95% of 2016
++
+         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].bit = 28;
+         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].nStartTime = 1199145601; // January 1, 2008
+         consensus.vDeployments[Consensus::DEPLOYMENT_TESTDUMMY].nTimeout = 1230767999; // December 31, 2008
+@@ -239,7 +248,8 @@ public:
+         base58Prefixes[EXT_SECRET_KEY] = {0x04, 0x88, 0xAD, 0xE4};
+ 
+         fMiningRequiresPeers = true;
+-        bech32_hrp = "bc";        fDefaultConsistencyChecks = false;
++        bech32_hrp = "bc";
++        fDefaultConsistencyChecks = false;
+         fRequireStandard = true;
+         fMineBlocksOnDemand = false;
+ 
+@@ -278,7 +288,8 @@ public:
+         consensus.nSubsidyHalvingInterval = 3360000;
+         consensus.FABHeight = 0;
+         consensus.ContractHeight = 192430 ;
+-        consensus.BIP16Height = 0;
++        consensus.EquihashFABHeight = 221370;
++        consensus.LWMAHeight = 221370;
+         consensus.BIP34Height = 0;
+         consensus.BIP34Hash = uint256S("0x0001cfb309df094182806bf71c66fd4d2d986ff2a309d211db602fc9a7db1835");
+         consensus.BIP65Height = 0; 
+@@ -289,10 +300,18 @@ public:
+         consensus.powLimit = uint256S("07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+         consensus.posLimit = uint256S("0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+         consensus.powLimitLegacy = uint256S("0003ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+-        consensus.nPowAveragingWindow = 17;
+-        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nPowAveragingWindow);
+-        consensus.nPowMaxAdjustDown = 32; // 32% adjustment down
+-        consensus.nPowMaxAdjustUp = 16; // 16% adjustment up
++
++        //Digishield parameters
++        consensus.nDigishieldPowAveragingWindow = 17;
++        assert(maxUint/UintToArith256(consensus.powLimit) >= consensus.nDigishieldPowAveragingWindow);
++        consensus.nDigishieldPowMaxAdjustDown = 32;
++        consensus.nDigishieldPowMaxAdjustUp = 16;
++
++        //LWMA parameters
++        consensus.nZawyLwmaAveragingWindow = 45;
++        consensus.bZawyLwmaSolvetimeLimitation = true;
++        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
++        consensus.MaxBlockInterval = 10; // 10 T
+ 
+         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days, for SHA256 mining only
+         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
+@@ -403,8 +422,10 @@ public:
+         consensus.BIP16Height = 0;
+         consensus.BIP34Height = 0; // BIP34 has not activated on regtest (far in the future so block v1 are not rejected in tests) // activate for fabcoin
+         consensus.BIP34Hash = uint256S("0x0e28ba5df35c1ac0893b7d37db241a6f4afac5498da89369067427dc369f9df3");
+-        consensus.BIP65Height = 0; // BIP65 activated on regtest (Used in rpc activation tests)
+-        consensus.BIP66Height = 0; // BIP66 activated on regtest (Used in rpc activation tests)
++        //consensus.BIP65Height = 0; // BIP65 activated on regtest (Used in rpc activation tests)
++        //consensus.BIP66Height = 0; // BIP66 activated on regtest (Used in rpc activation tests)
++        consensus.BIP65Height = 1351; // BIP65 activated on regtest (Used in rpc activation tests)
++        consensus.BIP66Height = 1251; // BIP66 activated on regtest (Used in rpc activation tests)
+         consensus.powLimit = uint256S("7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+         consensus.posLimit = uint256S("7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
+         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
+@@ -416,13 +437,21 @@ public:
+ 
+         consensus.FABHeight = 0x7fffffff;
+         consensus.ContractHeight = 100;
++        consensus.EquihashFABHeight = 0x7fffffff;
++        consensus.LWMAHeight = 0x7fffffff;
+         consensus.CoinbaseLock = 0;
+         consensus.ForceSegwit = false;
+ 
++        //Digishield parameters
++        consensus.nDigishieldPowAveragingWindow = 17;
++        consensus.nDigishieldPowMaxAdjustDown = 32;
++        consensus.nDigishieldPowMaxAdjustUp = 16;
+ 
+-        consensus.nPowAveragingWindow = 17;
+-        consensus.nPowMaxAdjustDown = 32;
+-        consensus.nPowMaxAdjustUp = 16;
++        //LWMA parameters
++        consensus.nZawyLwmaAveragingWindow = 45;
++        consensus.bZawyLwmaSolvetimeLimitation = true;
++        consensus.MaxFutureBlockTime = 20 * 60; // 20 mins
++        consensus.MaxBlockInterval = 10; // 10 T
+ 
+         consensus.nPowTargetTimespan = 1.75 * 24 * 60 * 60; // 1.75 days
+         consensus.nPowTargetSpacing = 1.25 * 60; // 75 seconds
+diff --git a/src/chainparams.h b/src/chainparams.h
+index 36ff57b..04df74d 100644
+--- a/src/chainparams.h
++++ b/src/chainparams.h
+@@ -63,9 +63,10 @@ public:
+     /** Policy: Filter transactions that do not match well-defined patterns */
+     bool RequireStandard() const { return fRequireStandard; }
+     uint64_t PruneAfterHeight() const { return nPruneAfterHeight; }
+-    unsigned int EquihashN(uint32_t nHeight = 0) const { return (nHeight < consensus.ContractHeight) || (strNetworkID != CBaseChainParams::MAIN) ? nEquihashN : 184; }
+-    unsigned int EquihashK(uint32_t nHeight = 0) const { return (nHeight < consensus.ContractHeight) || (strNetworkID != CBaseChainParams::MAIN) ? nEquihashK : 7; }
+-    int64_t GetnPowTargetSpacing( uint32_t nHeight = 0 ) const { return (nHeight < consensus.ContractHeight) ? consensus.nPowTargetSpacing : 2* consensus.nPowTargetSpacing; }
++    unsigned int EquihashN(uint32_t nHeight = 0) const { return (nHeight < consensus.EquihashFABHeight) /*|| (strNetworkID != CBaseChainParams::MAIN)*/ ? nEquihashN : 184; }
++    unsigned int EquihashK(uint32_t nHeight = 0) const { return (nHeight < consensus.EquihashFABHeight) /*|| (strNetworkID != CBaseChainParams::MAIN)*/ ? nEquihashK : 7; }
++    int64_t GetnPowTargetSpacing( uint32_t nHeight = 0 ) const { return (nHeight < consensus.EquihashFABHeight) ? consensus.nPowTargetSpacing : 2* consensus.nPowTargetSpacing; }
++
+     /** Make miner stop after a block is found. In RPC, don't return until nGenProcLimit blocks are generated */
+     bool MineBlocksOnDemand() const { return fMineBlocksOnDemand; }
+     /** Return the BIP70 network string (main, test or regtest) */
+diff --git a/src/consensus/params.h b/src/consensus/params.h
+index 434079b..72778bb 100644
+--- a/src/consensus/params.h
++++ b/src/consensus/params.h
+@@ -62,8 +62,14 @@ struct Params {
+     int BIP66Height;
+     /** Block height at which Fabcoin Equihash hard fork becomes active */
+     uint32_t FABHeight;
++    /** Block height at which LWMA becomes active */
++    uint32_t LWMAHeight;
+     /** Block height at which Fabcoin Smart Contract hard fork becomes active */
+     uint32_t ContractHeight;
++    /** Block height at which EquihashFAB (184,7) becomes active */
++    uint32_t EquihashFABHeight;
++    /** Limit BITCOIN_MAX_FUTURE_BLOCK_TIME **/
++    int64_t MaxFutureBlockTime;
+     /** Block height before which the coinbase subsidy will be locked for the same period */
+     int CoinbaseLock;
+     /** whether segwit is active */
+@@ -87,7 +93,7 @@ struct Params {
+     bool fPoSNoRetargeting;
+     int64_t nPowTargetSpacing;
+     int64_t nPowTargetTimespan;
+-    int64_t DifficultyAdjustmentInterval() const { return nPowTargetTimespan / nPowTargetSpacing; }
++    int64_t DifficultyAdjustmentInterval(uint32_t nheight=0) const { return nPowTargetTimespan / (nheight < EquihashFABHeight ? nPowTargetSpacing : 2*nPowTargetSpacing); }
+     uint256 nMinimumChainWork;
+     uint256 defaultAssumeValid;
+     int nLastPOWBlock;
+@@ -95,13 +101,19 @@ struct Params {
+     int nMPoSRewardRecipients;
+     int nFixUTXOCacheHFHeight;
+ 
+-    //Zcash logic for diff adjustment
+-    int64_t nPowAveragingWindow;
+-    int64_t nPowMaxAdjustDown;
+-    int64_t nPowMaxAdjustUp;
+-    int64_t AveragingWindowTimespan() const { return nPowAveragingWindow * nPowTargetSpacing; }
+-    int64_t MinActualTimespan() const { return (AveragingWindowTimespan() * (100 - nPowMaxAdjustUp  )) / 100; }
+-    int64_t MaxActualTimespan() const { return (AveragingWindowTimespan() * (100 + nPowMaxAdjustDown)) / 100; }
++    // Params for Zawy's LWMA difficulty adjustment algorithm.
++    int64_t nZawyLwmaAveragingWindow;
++    bool bZawyLwmaSolvetimeLimitation;
++    uint8_t MaxBlockInterval;
++
++    //Digishield logic for difficulty adjustment
++    int64_t nDigishieldPowAveragingWindow;
++    int64_t nDigishieldPowMaxAdjustDown;
++    int64_t nDigishieldPowMaxAdjustUp;
++
++    int64_t DigishieldAveragingWindowTimespan(uint32_t nheight=0) const { return nDigishieldPowAveragingWindow * (nheight < EquihashFABHeight ? nPowTargetSpacing : 2*nPowTargetSpacing); }
++    int64_t DigishieldMinActualTimespan(uint32_t nheight=0) const { return (DigishieldAveragingWindowTimespan(nheight) * (100 - nDigishieldPowMaxAdjustUp  )) / 100; }
++    int64_t DigishieldMaxActualTimespan(uint32_t nheight=0) const { return (DigishieldAveragingWindowTimespan(nheight) * (100 + nDigishieldPowMaxAdjustDown)) / 100; }
+ };
+ } // namespace Consensus
+ 
+diff --git a/src/miner.cpp b/src/miner.cpp
+index ff7cd15..f550a62 100644
+--- a/src/miner.cpp
++++ b/src/miner.cpp
+@@ -79,6 +79,15 @@ int64_t UpdateTime(CBlockHeader* pblock, const Consensus::Params& consensusParam
+     return nNewTime - nOldTime;
+ }
+ 
++bool IsBlockTooLate(CBlockHeader* pblock, const Consensus::Params& consensusParams, const CBlockIndex* pindexPrev)
++{
++    if( GetAdjustedTime() > std::max(pblock->GetBlockTime(), pindexPrev->GetBlockTime()) + Params().GetnPowTargetSpacing(pindexPrev->nHeight+1) * consensusParams.MaxBlockInterval ) 
++    {
++        return true;
++    }
++    return false;
++}
++
+ BlockAssembler::Options::Options() {
+     blockMinFeeRate = CFeeRate(DEFAULT_BLOCK_MIN_TX_FEE);
+     nBlockMaxWeight = DEFAULT_BLOCK_MAX_WEIGHT;
+@@ -285,7 +294,7 @@ std::unique_ptr<CBlockTemplate> BlockAssembler::CreateNewBlock(const CScript& sc
+     pblock->hashPrevBlock  = pindexPrev->GetBlockHash();
+     pblock->nHeight        = pindexPrev->nHeight + 1;
+     memset(pblock->nReserved, 0, sizeof(pblock->nReserved));
+-
++    pblock->nBits = GetNextWorkRequired(pindexPrev, pblock, chainparams.GetConsensus(),fProofOfStake);
+ 
+     arith_uint256 nonce;
+     if ((uint32_t)nHeight >= (uint32_t)chainparams.GetConsensus().FABHeight) {
+@@ -1191,8 +1200,8 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
+             n = chainparams.EquihashN(pblock->nHeight);
+             k = chainparams.EquihashK(pblock->nHeight);
+ 
+-            LogPrintf("FabcoinMiner mining   with %u transactions in block (%u bytes) @(%s)  \n", pblock->vtx.size(),
+-                ::GetSerializeSize(*pblock, SER_NETWORK, PROTOCOL_VERSION), conf.useGPU?"GPU":"CPU" );
++            LogPrintf("FabcoinMiner mining   with %u transactions in block (%u bytes) @(%s)  n=%d, k=%d\n", pblock->vtx.size(),
++                ::GetSerializeSize(*pblock, SER_NETWORK, PROTOCOL_VERSION), conf.useGPU?"GPU":"CPU", n, k );
+ 
+             headerlen = (pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight) ? CBlockHeader::HEADER_SIZE : CBlockHeader::HEADER_NEWSIZE;
+             //
+@@ -1204,9 +1213,9 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
+ 
+             nCounter = 0;
+             if (conf.useGPU)
+-                LogPrint(BCLog::POW, "Equihash solver (%d,%d) in GPU (%u, %u) with nNonce = %s hashTarget=%s\n", n, k, conf.currentPlatform, conf.currentDevice, pblock->nNonce.ToString(), hashTarget.GetHex());
++                LogPrint(BCLog::POW, "Equihash solver in GPU (%u, %u) with nNonce = %s hashTarget=%s\n", conf.currentPlatform, conf.currentDevice, pblock->nNonce.ToString(), hashTarget.GetHex());
+             else 
+-                LogPrint(BCLog::POW, "Equihash solver (%d,%d) in CPU with nNonce = %s hashTarget=%s\n", n, k, pblock->nNonce.ToString(), hashTarget.GetHex());
++                LogPrint(BCLog::POW, "Equihash solver in CPU with nNonce = %s hashTarget=%s\n", pblock->nNonce.ToString(), hashTarget.GetHex());
+   
+             double secs, solps;
+             g_nSols[thr_id] = 0;
+@@ -1350,6 +1359,17 @@ void static FabcoinMiner(const CChainParams& chainparams, GPUConfig conf, int th
+                 //    break; // Recreate the block if the clock has run backwards,
+ 
+                 // so that we can use the correct time.
++
++
++                if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
++                {
++                    // check if the new block will come too late. If so, create the block again to change block time
++                    if( IsBlockTooLate( pblock, chainparams.GetConsensus(), pindexPrev ) )
++                    {
++                        break;
++                    }
++                }
++
+                 if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
+                 {
+                     // Changing pblock->nTime can change work required on testnet:
+@@ -1500,7 +1520,7 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
+ 
+             try
+             {
+-                if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight)   // before fork
++                if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().EquihashFABHeight)   // before fork
+                 {
+                     if( g_solver184_7 ) 
+                     {
+@@ -1562,7 +1582,7 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
+                 try {
+                     bool found = false;
+ 
+-                    if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().ContractHeight )   // before fork
++                    if ( pblock->nHeight < (uint32_t)chainparams.GetConsensus().EquihashFABHeight )   // before fork
+                     {
+                         if( g_solver )
+                             found = g_solver->solve((unsigned char *)pblock, header, headerlen);
+@@ -1602,6 +1622,17 @@ void static FabcoinMinerCuda(const CChainParams& chainparams, GPUConfig conf, in
+                 //if (UpdateTime(pblock, chainparams.GetConsensus(), pindexPrev) < 0)
+                 //    break; // Recreate the block if the clock has run backwards,
+                 // so that we can use the correct time.
++
++
++                if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
++                {
++                    // check if the new block will come too late. If so, create the block again to change block time
++                    if( IsBlockTooLate( pblock, chainparams.GetConsensus(), pindexPrev ) )
++                    {
++                        break;
++                    }
++                }
++
+                 if (chainparams.GetConsensus().fPowAllowMinDifficultyBlocks)
+                 {
+                     // Changing pblock->nTime can change work required on testnet:
+@@ -1733,15 +1764,29 @@ void GenerateFabcoins(bool fGenerate, int nThreads, const CChainParams& chainpar
+                     devices[device].getInfo(CL_DEVICE_GLOBAL_MEM_SIZE, &result);
+ 
+                     int maxThreads = nThreads;
++                    CBlockIndex* pindexPrev = chainActive.Tip();
++
+                     if (!conf.forceGenProcLimit) {
+-                        if (result > 7500000000) {
+-                            maxThreads = std::min(4, nThreads);
+-                        } else if (result > 5500000000) {
+-                            maxThreads = std::min(3, nThreads);
+-                        } else if (result > 3500000000) {
+-                            maxThreads = std::min(2, nThreads);
+-                        } else {
+-                            maxThreads = std::min(1, nThreads);
++
++                        if( (pindexPrev->nHeight+1) < chainparams.GetConsensus().EquihashFABHeight )
++                        {
++                            if (result > 7500000000) {
++                                maxThreads = std::min(4, nThreads);
++                            } else if (result > 5500000000) {
++                                maxThreads = std::min(3, nThreads);
++                            } else if (result > 3500000000) {
++                                maxThreads = std::min(2, nThreads);
++                            } else {
++                                maxThreads = std::min(1, nThreads);
++                            }
++                        }
++                        else
++                        {
++                            if (result > 7500000000) {
++                                maxThreads = std::min(2, nThreads);
++                            } else {
++                                maxThreads = std::min(1, nThreads);
++                            }
+                         }
+                     }
+ 
+diff --git a/src/net_processing.cpp b/src/net_processing.cpp
+index b1bdfe2..e6ca3e3 100644
+--- a/src/net_processing.cpp
++++ b/src/net_processing.cpp
+@@ -454,13 +454,13 @@ bool TipMayBeStale(const Consensus::Params &consensusParams)
+     if (g_last_tip_update == 0) {
+         g_last_tip_update = GetTime();
+     }
+-    return g_last_tip_update < GetTime() - consensusParams.nPowTargetSpacing * 3 && mapBlocksInFlight.empty();
++    return g_last_tip_update < GetTime() - Params().GetnPowTargetSpacing(chainActive.Height())* 3 && mapBlocksInFlight.empty();
+ }
+ 
+ // Requires cs_main
+ bool CanDirectFetch(const Consensus::Params &consensusParams)
+ {
+-    return chainActive.Tip()->GetBlockTime() > GetAdjustedTime() - consensusParams.nPowTargetSpacing * 20;
++    return chainActive.Tip()->GetBlockTime() > GetAdjustedTime() - Params().GetnPowTargetSpacing (chainActive.Height()) * 20;
+ }
+ 
+ // Requires cs_main
+@@ -1991,7 +1991,8 @@ bool static ProcessMessage(CNode* pfrom, const std::string& strCommand, CDataStr
+             }
+             // If pruning, don't inv blocks unless we have on disk and are likely to still have
+             // for some reasonable time window (1 hour) that block relay might require.
+-            const int nPrunedBlocksLikelyToHave = MIN_BLOCKS_TO_KEEP - 3600 / chainparams.GetConsensus().nPowTargetSpacing;
++            const int nPrunedBlocksLikelyToHave = MIN_BLOCKS_TO_KEEP - 3600 / chainparams.GetnPowTargetSpacing(chainActive.Height()) ;
++
+             if (fPruneMode && (!(pindex->nStatus & BLOCK_HAVE_DATA) || pindex->nHeight <= chainActive.Tip()->nHeight - nPrunedBlocksLikelyToHave))
+             {
+                 LogPrint(BCLog::NET, " getblocks stopping, pruned or too old block at %d %s\n", pindex->nHeight, pindex->GetBlockHash().ToString());
+@@ -3273,7 +3274,8 @@ bool PeerLogicValidation::SendMessages(CNode* pto, std::atomic<bool>& interruptM
+             // Only actively request headers from a single peer, unless we're close to today.
+             if ((nSyncStarted == 0 && fFetch) || pindexBestHeader->GetBlockTime() > GetAdjustedTime() - 24 * 60 * 60) {
+                 state.fSyncStarted = true;
+-                state.nHeadersSyncTimeout = GetTimeMicros() + HEADERS_DOWNLOAD_TIMEOUT_BASE + HEADERS_DOWNLOAD_TIMEOUT_PER_HEADER * (GetAdjustedTime() - pindexBestHeader->GetBlockTime())/(consensusParams.nPowTargetSpacing);
++                state.nHeadersSyncTimeout = GetTimeMicros() + HEADERS_DOWNLOAD_TIMEOUT_BASE + HEADERS_DOWNLOAD_TIMEOUT_PER_HEADER * (GetAdjustedTime() - pindexBestHeader->GetBlockTime())/(Params().GetnPowTargetSpacing(pindexBestHeader->nHeight ));
++
+                 nSyncStarted++;
+                 const CBlockIndex *pindexStart = pindexBestHeader;
+                 /* If possible, start at the block preceding the currently
+@@ -3591,7 +3593,7 @@ bool PeerLogicValidation::SendMessages(CNode* pto, std::atomic<bool>& interruptM
+         if (state.vBlocksInFlight.size() > 0) {
+             QueuedBlock &queuedBlock = state.vBlocksInFlight.front();
+             int nOtherPeersWithValidatedDownloads = nPeersWithValidatedDownloads - (state.nBlocksInFlightValidHeaders > 0);
+-            if (nNow > state.nDownloadingSince + consensusParams.nPowTargetSpacing * (BLOCK_DOWNLOAD_TIMEOUT_BASE + BLOCK_DOWNLOAD_TIMEOUT_PER_PEER * nOtherPeersWithValidatedDownloads)) {
++            if ( nNow > state.nDownloadingSince + Params().GetnPowTargetSpacing(chainActive.Height()) * (BLOCK_DOWNLOAD_TIMEOUT_BASE + BLOCK_DOWNLOAD_TIMEOUT_PER_PEER * nOtherPeersWithValidatedDownloads)) {
+                 LogPrintf("Timeout downloading block %s from peer=%d, disconnecting\n", queuedBlock.hash.ToString(), pto->GetId());
+                 pto->fDisconnect = true;
+                 return true;
+diff --git a/src/pow.cpp b/src/pow.cpp
+index 440db9b..363193e 100644
+--- a/src/pow.cpp
++++ b/src/pow.cpp
+@@ -45,18 +45,179 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
+     if (pindexLast == NULL)
+         return nTargetLimit;
+ 
++    if (params.fPowNoRetargeting)
++        return pindexLast->nBits;
++
+     // first block
+     const CBlockIndex* pindexPrev = GetLastBlockIndex(pindexLast, fProofOfStake);
+     if (pindexPrev->pprev == NULL)
+         return nTargetLimit;
+ 
++    uint32_t nHeight = pindexPrev->nHeight + 1;
++
++    if (nHeight < params.LWMAHeight)
++    {
++        // Digishield v3.
++        return DigishieldGetNextWorkRequired(pindexPrev, pblock, params);
++    } 
++    else if (nHeight < params.LWMAHeight + params.nZawyLwmaAveragingWindow && params.LWMAHeight == params.EquihashFABHeight ) 
++    {
++        // Reduce the difficulty of the first forked block by 100x and keep it for N blocks.
++        if (nHeight == params.LWMAHeight)
++        {
++            return ReduceDifficultyBy(pindexPrev, 100, params);
++        }
++        else
++        {
++            return pindexPrev->nBits;
++        }
++    }
++    else
++    {
++        // Zawy's LWMA.
++        return LwmaGetNextWorkRequired(pindexPrev, pblock, params);
++    }
++}
++
++unsigned int LwmaGetNextWorkRequired(const CBlockIndex* pindexPrev, const CBlockHeader *pblock, const Consensus::Params& params)
++{
++    // If the new block's timestamp is more than 10 * T minutes
++    // then halve the difficulty
++    int64_t diff = pblock->GetBlockTime() - pindexPrev->GetBlockTime();
++    if ( params.fPowAllowMinDifficultyBlocks && diff > ( pindexPrev->nHeight+1 < params.EquihashFABHeight ? params.nPowTargetSpacing : 2*params.nPowTargetSpacing ) * params.MaxBlockInterval ) 
++    {
++#if 1
++        LogPrintf("The new block(height=%d) will come too late. Use minimum difficulty.\n", pblock->nHeight);
++        return UintToArith256(params.PowLimit(true)).GetCompact();
++#else
++        arith_uint256 target;
++        target.SetCompact(pindexPrev->nBits);
++        int n = diff / ( pindexPrev->nHeight+1<params.EquihashFABHeight:params.nPowTargetSpacing:2*params.nPowTargetSpacing ) * params.MaxBlockInterval);
++
++        while( n-- > 0 )
++        {
++            target <<= 1;
++        }
++
++        const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
++        if (target > pow_limit) {
++            target = pow_limit;
++        }
++
++        LogPrintf("The new block(height=%d) will come too late. Halve the difficulty to %x.\n", pblock->nHeight, target.GetCompact());
++        return target.GetCompact();
++#endif
++    }
++    return LwmaCalculateNextWorkRequired(pindexPrev, params);
++}
++
++unsigned int LwmaCalculateNextWorkRequired(const CBlockIndex* pindexPrev, const Consensus::Params& params)
++{
+     if (params.fPowNoRetargeting)
+-        return pindexLast->nBits;
++    {
++        return pindexPrev->nBits;
++    }
++
++    const int height = pindexPrev->nHeight + 1;
++
++    const int64_t T = height < params.EquihashFABHeight ? params.nPowTargetSpacing : 2*params.nPowTargetSpacing;
++    const int N = params.nZawyLwmaAveragingWindow;
++    const int k = (N+1)/2 * 0.998 * T;  // ( (N+1)/2 * adjust * T )
++
++    assert(height > N);
++
++    arith_uint256 sum_target, sum_last10_target,sum_last5_target;;
++    int sum_time = 0, nWeight = 0;
++
++    int sum_last10_time=0;  //Solving time of the last ten block
++    int sum_last5_time=0;
++
++    // Loop through N most recent blocks.
++    for (int i = height - N; i < height; i++) {
++        const CBlockIndex* block = pindexPrev->GetAncestor(i);
++        const CBlockIndex* block_Prev = block->GetAncestor(i - 1);
++        int64_t solvetime = block->GetBlockTime() - block_Prev->GetBlockTime();
++
++        if (params.bZawyLwmaSolvetimeLimitation && solvetime > 6 * T) {
++            solvetime = 6 * T;
++        }
++
++        nWeight++;
++        sum_time += solvetime * nWeight;  // Weighted solvetime sum.
++
++        // Target sum divided by a factor, (k N^2).
++        // The factor is a part of the final equation. However we divide sum_target here to avoid
++        // potential overflow.
++        arith_uint256 target;
++        target.SetCompact(block->nBits);
++        sum_target += target / (k * N * N);
++
++        if(i >= height-10)
++        {
++            sum_last10_time += solvetime;
++            sum_last10_target += target;
++            if(i >= height-5)
++            {
++                sum_last5_time += solvetime;
++                sum_last5_target += target;
++            }
++        }
++    }
++
++    // Keep sum_time reasonable in case strange solvetimes occurred.
++    if (sum_time < N * k / 10) {
++        sum_time = N * k / 10;
++    }
++
++    const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
++    arith_uint256 next_target = sum_time * sum_target;
++
++#if 1
++    /*if the last 10 blocks are generated in 5 minutes, we tripple the difficulty of average of the last 10 blocks*/
++    if( sum_last5_time <= T )
++    {
++        arith_uint256 avg_last5_target;
++        avg_last5_target = sum_last5_target/5;
++        if(next_target > avg_last5_target/4)  next_target = avg_last5_target/4;
++    }
++    else if(sum_last10_time <= 2 * T)
++    {
++        arith_uint256 avg_last10_target;
++        avg_last10_target = sum_last10_target/10;
++        if(next_target > avg_last10_target/3)  next_target = avg_last10_target/3;
++    }
++    else if(sum_last10_time <= 5 * T)
++    {
++        arith_uint256 avg_last10_target;
++        avg_last10_target = sum_last10_target/10;
++        if(next_target > avg_last10_target*2/3)  next_target = avg_last10_target*2/3;
++    }
++
++    arith_uint256 last_target;
++    last_target.SetCompact(pindexPrev->nBits);
++    if( next_target > last_target * 13/10 ) next_target = last_target * 13/10;
++    /*in case difficulty drops too soon compared to the last block, especially
++     *when the effect of the last rule wears off in the new block
++     *DAA will switch to normal LWMA and cause dramatically diff drops*/
++#endif
++
++    if (next_target > pow_limit) {
++        next_target = pow_limit;
++    }
++
++    return next_target.GetCompact();
++}
++
++unsigned int DigishieldGetNextWorkRequired(const CBlockIndex* pindexPrev, const CBlockHeader *pblock,
++                                           const Consensus::Params& params)
++{
++    assert(pindexPrev != nullptr);
++    unsigned int nProofOfWorkLimit = UintToArith256(params.PowLimit(true)).GetCompact();
+ 
+     // Find the first block in the averaging interval
+-    const CBlockIndex* pindexFirst = pindexLast;
++    const CBlockIndex* pindexFirst = pindexPrev;
+     arith_uint256 bnTot {0};
+-    for (int i = 0; pindexFirst && i < params.nPowAveragingWindow; i++) {
++    for (int i = 0; pindexFirst && i < params.nDigishieldPowAveragingWindow; i++) {
+         arith_uint256 bnTmp;
+         bnTmp.SetCompact(pindexFirst->nBits);
+         bnTot += bnTmp;
+@@ -65,28 +226,29 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
+ 
+     // Check we have enough blocks
+     if (pindexFirst == NULL)
+-        return nTargetLimit;
++        return nProofOfWorkLimit;
+ 
+-    arith_uint256 bnAvg {bnTot / params.nPowAveragingWindow};
+-
+-    return CalculateNextWorkRequired(bnAvg, pindexLast->GetMedianTimePast(), pindexFirst->GetMedianTimePast(), params );
++    arith_uint256 bnAvg {bnTot / params.nDigishieldPowAveragingWindow};
++    return DigishieldCalculateNextWorkRequired(pindexPrev, bnAvg, pindexPrev->GetMedianTimePast(), pindexFirst->GetMedianTimePast(), params);
+ }
+-unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params)
++
++
++unsigned int DigishieldCalculateNextWorkRequired(const CBlockIndex* pindexPrev, arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params)
+ {
+     // Limit adjustment
+     // Use medians to prevent time-warp attacks
+     int64_t nActualTimespan = nLastBlockTime - nFirstBlockTime;
+-    nActualTimespan = params.AveragingWindowTimespan() + (nActualTimespan - params.AveragingWindowTimespan())/4;
++    nActualTimespan = params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight) + (nActualTimespan - params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight))/4;
+ 
+-    if (nActualTimespan < params.MinActualTimespan())
+-        nActualTimespan = params.MinActualTimespan();
+-    if (nActualTimespan > params.MaxActualTimespan())
+-        nActualTimespan = params.MaxActualTimespan();
++    if (nActualTimespan < params.DigishieldMinActualTimespan(pindexPrev->nHeight))
++        nActualTimespan = params.DigishieldMinActualTimespan(pindexPrev->nHeight);
++    if (nActualTimespan > params.DigishieldMaxActualTimespan(pindexPrev->nHeight))
++        nActualTimespan = params.DigishieldMaxActualTimespan(pindexPrev->nHeight);
+ 
+     // Retarget
+-    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
++    const arith_uint256 bnPowLimit = UintToArith256(params.PowLimit(true));
+     arith_uint256 bnNew {bnAvg};
+-    bnNew /= params.AveragingWindowTimespan();
++    bnNew /= params.DigishieldAveragingWindowTimespan(pindexPrev->nHeight);
+     bnNew *= nActualTimespan;
+ 
+     if (bnNew > bnPowLimit)
+@@ -95,6 +257,22 @@ unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTi
+     return bnNew.GetCompact();
+ }
+ 
++unsigned int ReduceDifficultyBy(const CBlockIndex* pindexPrev, int64_t multiplier, const Consensus::Params& params)
++{
++    arith_uint256 target;
++
++    target.SetCompact(pindexPrev->nBits);
++    target *= multiplier;
++
++    const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
++    if (target > pow_limit)
++    {
++        target = pow_limit;
++    }
++    return target.GetCompact();
++}
++
++
+ bool CheckEquihashSolution(const CBlockHeader *pblock, const CChainParams& params)
+ {
+ 
+diff --git a/src/pow.h b/src/pow.h
+index 76ae7ed..1bbc861 100644
+--- a/src/pow.h
++++ b/src/pow.h
+@@ -20,6 +20,17 @@ unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHead
+ //unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast, int64_t nFirstBlockTime, const Consensus::Params&);
+ unsigned int CalculateNextWorkRequired(arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params);
+ 
++/** Zawy's LWMA - next generation algorithm  */
++unsigned int LwmaGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params&);
++
++unsigned int LwmaCalculateNextWorkRequired(const CBlockIndex* pindexLast, const Consensus::Params& params);
++
++/** Digishield v3 - used in Fabcoin mainnet currently */
++unsigned int DigishieldGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params&);
++unsigned int DigishieldCalculateNextWorkRequired(const CBlockIndex* pindexLast, arith_uint256 bnAvg, int64_t nLastBlockTime, int64_t nFirstBlockTime, const Consensus::Params& params);
++
++/** Reduce the difficulty by a given multiplier. It doesn't check uint256 overflow! */
++unsigned int ReduceDifficultyBy(const CBlockIndex* pindexLast, int64_t multiplier, const Consensus::Params& params);
+ 
+ /** Check whether the Equihash solution in a block header is valid */
+ bool CheckEquihashSolution(const CBlockHeader *pblock, const CChainParams&);
+diff --git a/src/qt/fabcoingui.cpp b/src/qt/fabcoingui.cpp
+index dcd5cf6..ed7b8cc 100644
+--- a/src/qt/fabcoingui.cpp
++++ b/src/qt/fabcoingui.cpp
+@@ -926,7 +926,8 @@ void FabcoinGUI::updateHeadersSyncProgressLabel()
+ {
+     int64_t headersTipTime = clientModel->getHeaderTipTime();
+     int headersTipHeight = clientModel->getHeaderTipHeight();
+-    int estHeadersLeft = (GetTime() - headersTipTime) / Params().GetConsensus().nPowTargetSpacing;
++    int estHeadersLeft = (GetTime() - headersTipTime) / Params().GetnPowTargetSpacing(headersTipHeight);
++
+     if (estHeadersLeft > HEADER_HEIGHT_DELTA_SYNC)
+         progressBarLabel->setText(tr("Syncing Headers (%1%)...").arg(QString::number(100.0 / (headersTipHeight+estHeadersLeft)*headersTipHeight, 'f', 1)));
+ }
+@@ -1349,7 +1350,9 @@ void FabcoinGUI::updateStakingIcon()
+         uint64_t nWeight = this->nWeight;
+         uint64_t nNetworkWeight = GetPoSKernelPS();
+         const Consensus::Params& consensusParams = Params().GetConsensus();
+-        int64_t nTargetSpacing = consensusParams.nPowTargetSpacing;
++
++        int headersTipHeight = clientModel->getHeaderTipHeight();
++        int64_t nTargetSpacing = Params().GetnPowTargetSpacing(headersTipHeight);
+ 
+         unsigned nEstimateTime = nTargetSpacing * nNetworkWeight / nWeight;
+ 
+diff --git a/src/qt/modaloverlay.cpp b/src/qt/modaloverlay.cpp
+index b000df7..1c8d507 100644
+--- a/src/qt/modaloverlay.cpp
++++ b/src/qt/modaloverlay.cpp
+@@ -139,7 +139,8 @@ void ModalOverlay::tipUpdate(int count, const QDateTime& blockDate, double nVeri
+ 
+     // estimate the number of headers left based on nPowTargetSpacing
+     // and check if the gui is not aware of the best header (happens rarely)
+-    int estimateNumHeadersLeft = bestHeaderDate.secsTo(currentDate) / Params().GetConsensus().nPowTargetSpacing;
++     
++    int estimateNumHeadersLeft = bestHeaderDate.secsTo(currentDate) / Params().GetnPowTargetSpacing(bestHeaderHeight);
+     bool hasBestHeader = bestHeaderHeight >= count;
+ 
+     // show remaining number of blocks
+diff --git a/src/qt/sendcoinsdialog.cpp b/src/qt/sendcoinsdialog.cpp
+index e548265..4ee64bc 100644
+--- a/src/qt/sendcoinsdialog.cpp
++++ b/src/qt/sendcoinsdialog.cpp
+@@ -164,7 +164,9 @@ void SendCoinsDialog::setModel(WalletModel *_model)
+         coinControlUpdateLabels();
+ 
+         // fee section
++        //int headersTipHeight = clientModel->getHeaderTipHeight();
+         for (const int n : confTargets) {
++            //ui->confTargetSelector->addItem(tr("%1 (%2 blocks)").arg(GUIUtil::formatNiceTimeOffset(n*Params().GetnPowTargetSpacing(headersTipHeight))).arg(n));
+             ui->confTargetSelector->addItem(tr("%1 (%2 blocks)").arg(GUIUtil::formatNiceTimeOffset(n*Params().GetConsensus().nPowTargetSpacing)).arg(n));
+         }
+         connect(ui->confTargetSelector, SIGNAL(currentIndexChanged(int)), this, SLOT(updateSmartFeeLabel()));
+diff --git a/src/rpc/blockchain.cpp b/src/rpc/blockchain.cpp
+index 904999f..7acce36 100644
+--- a/src/rpc/blockchain.cpp
++++ b/src/rpc/blockchain.cpp
+@@ -1915,7 +1915,7 @@ UniValue gettxoutset(const JSONRPCRequest& request)
+         + HelpExampleRpc("gettxoutset", "")
+         );
+ 
+-    UniValue ret(UniValue::VOBJ);
++    UniValue ret(UniValue::VARR);
+ 
+     CCoinsStats stats;
+     FlushStateToDisk();
+@@ -1943,9 +1943,10 @@ UniValue gettxoutset(const JSONRPCRequest& request)
+             {
+                 for( const CTxDestination addr: addresses )
+                 {
+-                    strUtxo << coin.nHeight << ", " << key.hash.ToString() << ", " << key.n << ", " << EncodeDestination(addr) << ", " << coin.out.nValue  << ", " << coin.fCoinBase;
++                    //strUtxo << coin.nHeight << ", " << CFabcoinAddress(addr).ToString() << ", " << coin.out.nValue ;
+ 
+-                    ret.push_back(Pair("UTXO", strUtxo.str()));
++                    strUtxo << coin.nHeight << ", " << key.hash.ToString() << ", " << key.n << ", " << CFabcoinAddress(addr).ToString() << ", " << coin.out.nValue ;
++                    ret.push_back(strUtxo.str());
+                 }
+             }
+             else
+@@ -2541,7 +2542,8 @@ UniValue getchaintxstats(const JSONRPCRequest& request)
+         );
+ 
+     const CBlockIndex* pindex;
+-    int blockcount = 30 * 24 * 60 * 60 / Params().GetConsensus().nPowTargetSpacing; // By default: 1 month
++
++    int blockcount = 30 * 24 * 60 * 60 / Params().GetnPowTargetSpacing(chainActive.Height()); // By default: 1 month
+ 
+     bool havehash = !request.params[1].isNull();
+     uint256 hash;
+diff --git a/src/rpc/mining.cpp b/src/rpc/mining.cpp
+index 39afd12..ea674cb 100644
+--- a/src/rpc/mining.cpp
++++ b/src/rpc/mining.cpp
+@@ -486,7 +486,7 @@ UniValue getstakinginfo(const JSONRPCRequest& request)
+     uint64_t nNetworkWeight = GetPoSKernelPS();
+     bool staking = nLastCoinStakeSearchInterval && nWeight;
+     const Consensus::Params& consensusParams = Params().GetConsensus();
+-    int64_t nTargetSpacing = consensusParams.nPowTargetSpacing;
++    int64_t nTargetSpacing = Params().GetnPowTargetSpacing(chainActive.Height());
+     uint64_t nExpectedTime = staking ? (nTargetSpacing * nNetworkWeight / nWeight) : 0;
+ 
+     UniValue obj(UniValue::VOBJ);
+diff --git a/src/test/pow_tests.cpp b/src/test/pow_tests.cpp
+index 2b9e826..d91ac3c 100644
+--- a/src/test/pow_tests.cpp
++++ b/src/test/pow_tests.cpp
+@@ -68,7 +68,8 @@ BOOST_AUTO_TEST_CASE(GetBlockProofEquivalentTime_test)
+     for (int i = 0; i < 10000; i++) {
+         blocks[i].pprev = i ? &blocks[i - 1] : nullptr;
+         blocks[i].nHeight = i;
+-        blocks[i].nTime = 1269211443 + i * chainParams->GetConsensus().nPowTargetSpacing;
++        blocks[i].nTime = 1269211443 + i * chainParams->GetnPowTargetSpacing(i);
++
+         blocks[i].nBits = 0x207fffff; /* target 0x7fffff000... */
+         blocks[i].nChainWork = i ? blocks[i - 1].nChainWork + GetBlockProof(blocks[i - 1]) : arith_uint256(0);
+     }
+diff --git a/src/validation.cpp b/src/validation.cpp
+index 96ba1cd..f56dfdd 100644
+--- a/src/validation.cpp
++++ b/src/validation.cpp
+@@ -4296,8 +4296,11 @@ static bool ContextualCheckBlockHeader(const CBlockHeader& block, CValidationSta
+         return state.Invalid(false, REJECT_INVALID, "time-too-old", "block's timestamp is too early");
+ 
+     // Check timestamp
+-    if (block.IsProofOfStake() && block.GetBlockTime() > FutureDrift(nAdjustedTime))
++    //if (block.IsProofOfStake() && block.GetBlockTime() > FutureDrift(nAdjustedTime)){
++    if (block.GetBlockTime() > nAdjustedTime + std::min(consensusParams.MaxFutureBlockTime, MAX_FUTURE_BLOCK_TIME)){
++        LogPrintf(" Debug block.GetBlockTime()=%d nAdjustedTime=%d MAX_FUTURE_BLOCK_TIME=%d MaxFutureBlockTime=%d futureDrift=%d", block.GetBlockTime(), nAdjustedTime, MAX_FUTURE_BLOCK_TIME, consensusParams.MaxFutereBlockTime, FutureDrift(nAdjustedTime) );
+         return state.Invalid(false, REJECT_INVALID, "time-too-new", "block timestamp too far in the future");
++    }
+ 
+     // Reject outdated version blocks when 95% (75% on testnet) of the network has upgraded:
+     // check for version 2, 3 and 4 upgrades
+diff --git a/test/functional/p2p_leak.py b/test/functional/p2p_leak.py
+index 1609c11..aeb8c1b 100755
+--- a/test/functional/p2p_leak.py
++++ b/test/functional/p2p_leak.py
+@@ -95,7 +95,8 @@ class P2PLeakTest(FabcoinTestFramework):
+         self.extra_args = [['-banscore='+str(banscore)]]
+ 
+     def run_test(self):
+-        self.nodes[0].setmocktime(1501545600)  # August 1st 2017
++        #self.nodes[0].setmocktime(1501545600)  # August 1st 2017
++        self.nodes[0].setmocktime(1504762080)
+ 
+         no_version_bannode = self.nodes[0].add_p2p_connection(CNodeNoVersionBan(), send_version=False)
+         no_version_idlenode = self.nodes[0].add_p2p_connection(CNodeNoVersionIdle(), send_version=False)
+@@ -112,6 +113,7 @@ class P2PLeakTest(FabcoinTestFramework):
+         wait_until(lambda: unsupported_service_bit7_node.ever_connected, timeout=10, lock=mininode_lock)
+ 
+         # Mine a block and make sure that it's not sent to the connected nodes
++        #print(self.nodes[0].getinfo())
+         self.nodes[0].generate(1)
+ 
+         #Give the node enough time to possibly leak out a message
+diff --git a/test/functional/test_runner.py b/test/functional/test_runner.py
+index 85d0d91..735fc1a 100755
+--- a/test/functional/test_runner.py
++++ b/test/functional/test_runner.py
+@@ -87,7 +87,7 @@ BASE_SCRIPTS= [
+     'mempool_resurrect.py',
+     'wallet_txn_doublespend.py --mineblock',
+     'wallet_txn_clone.py',
+-    'wallet_txn_clone.py --segwit',
++    ####'wallet_txn_clone.py --segwit',
+     'rpc_getchaintips.py',
+     'interface_rest.py',
+     'mempool_spend_coinbase.py',
diff --git a/src/test/pow_tests.cpp b/src/test/pow_tests.cpp
index 2b9e826..d91ac3c 100644
--- a/src/test/pow_tests.cpp
+++ b/src/test/pow_tests.cpp
@@ -68,7 +68,8 @@ BOOST_AUTO_TEST_CASE(GetBlockProofEquivalentTime_test)
     for (int i = 0; i < 10000; i++) {
         blocks[i].pprev = i ? &blocks[i - 1] : nullptr;
         blocks[i].nHeight = i;
-        blocks[i].nTime = 1269211443 + i * chainParams->GetConsensus().nPowTargetSpacing;
+        blocks[i].nTime = 1269211443 + i * chainParams->GetnPowTargetSpacing(i);
+
         blocks[i].nBits = 0x207fffff; /* target 0x7fffff000... */
         blocks[i].nChainWork = i ? blocks[i - 1].nChainWork + GetBlockProof(blocks[i - 1]) : arith_uint256(0);
     }
diff --git a/src/validation.cpp b/src/validation.cpp
index 96ba1cd..f56dfdd 100644
--- a/src/validation.cpp
+++ b/src/validation.cpp
@@ -4296,8 +4296,11 @@ static bool ContextualCheckBlockHeader(const CBlockHeader& block, CValidationSta
         return state.Invalid(false, REJECT_INVALID, "time-too-old", "block's timestamp is too early");
 
     // Check timestamp
-    if (block.IsProofOfStake() && block.GetBlockTime() > FutureDrift(nAdjustedTime))
+    //if (block.IsProofOfStake() && block.GetBlockTime() > FutureDrift(nAdjustedTime)){
+    if (block.GetBlockTime() > nAdjustedTime + std::min(consensusParams.MaxFutureBlockTime, MAX_FUTURE_BLOCK_TIME)){
+        LogPrintf(" Debug block.GetBlockTime()=%d nAdjustedTime=%d MAX_FUTURE_BLOCK_TIME=%d MaxFutureBlockTime=%d futureDrift=%d", block.GetBlockTime(), nAdjustedTime, MAX_FUTURE_BLOCK_TIME, consensusParams.MaxFutereBlockTime, FutureDrift(nAdjustedTime) );
         return state.Invalid(false, REJECT_INVALID, "time-too-new", "block timestamp too far in the future");
+    }
 
     // Reject outdated version blocks when 95% (75% on testnet) of the network has upgraded:
     // check for version 2, 3 and 4 upgrades
diff --git a/test/functional/p2p_leak.py b/test/functional/p2p_leak.py
index 1609c11..aeb8c1b 100755
--- a/test/functional/p2p_leak.py
+++ b/test/functional/p2p_leak.py
@@ -95,7 +95,8 @@ class P2PLeakTest(FabcoinTestFramework):
         self.extra_args = [['-banscore='+str(banscore)]]
 
     def run_test(self):
-        self.nodes[0].setmocktime(1501545600)  # August 1st 2017
+        #self.nodes[0].setmocktime(1501545600)  # August 1st 2017
+        self.nodes[0].setmocktime(1504762080)
 
         no_version_bannode = self.nodes[0].add_p2p_connection(CNodeNoVersionBan(), send_version=False)
         no_version_idlenode = self.nodes[0].add_p2p_connection(CNodeNoVersionIdle(), send_version=False)
@@ -112,6 +113,7 @@ class P2PLeakTest(FabcoinTestFramework):
         wait_until(lambda: unsupported_service_bit7_node.ever_connected, timeout=10, lock=mininode_lock)
 
         # Mine a block and make sure that it's not sent to the connected nodes
+        #print(self.nodes[0].getinfo())
         self.nodes[0].generate(1)
 
         #Give the node enough time to possibly leak out a message
diff --git a/test/functional/test_runner.py b/test/functional/test_runner.py
index 85d0d91..735fc1a 100755
--- a/test/functional/test_runner.py
+++ b/test/functional/test_runner.py
@@ -87,7 +87,7 @@ BASE_SCRIPTS= [
     'mempool_resurrect.py',
     'wallet_txn_doublespend.py --mineblock',
     'wallet_txn_clone.py',
-    'wallet_txn_clone.py --segwit',
+    ####'wallet_txn_clone.py --segwit',
     'rpc_getchaintips.py',
     'interface_rest.py',
     'mempool_spend_coinbase.py',
