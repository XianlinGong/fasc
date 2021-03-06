# Copyright (c) 2013-2016 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

DIST_SUBDIRS = secp256k1 univalue

AM_LDFLAGS = $(PTHREAD_CFLAGS) $(LIBTOOL_LDFLAGS) $(HARDENED_LDFLAGS)
AM_CXXFLAGS = $(HARDENED_CXXFLAGS) $(ERROR_CXXFLAGS) -DETH_FATDB=1
AM_CPPFLAGS = $(HARDENED_CPPFLAGS) -DFABCOIN_BUILD
EXTRA_LIBRARIES =

if EMBEDDED_UNIVALUE
LIBUNIVALUE = univalue/libunivalue.la

$(LIBUNIVALUE): $(wildcard univalue/lib/*) $(wildcard univalue/include/*)
	$(AM_V_at)$(MAKE) $(AM_MAKEFLAGS) -C $(@D) $(@F)
else
LIBUNIVALUE = $(UNIVALUE_LIBS)
endif

FABCOIN_INCLUDES=-I$(builddir) $(BDB_CPPFLAGS) $(BOOST_CPPFLAGS) $(LEVELDB_CPPFLAGS) $(CRYPTO_CFLAGS) $(SSL_CFLAGS) -I$(srcdir)/cpp-ethereum/utils

FABCOIN_INCLUDES += -I$(srcdir)/secp256k1/include
FABCOIN_INCLUDES += $(UNIVALUE_CFLAGS)

FABCOIN_INCLUDES += -I$(srcdir)/cpp-ethereum

LIBFABCOIN_SERVER=libfabcoin_server.a
LIBFABCOIN_COMMON=libfabcoin_common.a
LIBFABCOIN_CONSENSUS=libfabcoin_consensus.a
LIBFABCOIN_CLI=libfabcoin_cli.a
LIBFABCOIN_UTIL=libfabcoin_util.a
LIBFABCOIN_CRYPTO=crypto/libfabcoin_crypto.a
LIBFABCOINQT=qt/libfabcoinqt.a
LIBSECP256K1=secp256k1/libsecp256k1.la
LIBCRYPTOPP=cryptopp/libcryptopp.a


if ENABLE_ZMQ
LIBFABCOIN_ZMQ=libfabcoin_zmq.a
endif
if BUILD_FABCOIN_LIBS
LIBFABCOINCONSENSUS=libfabcoinconsensus.la
endif
if ENABLE_WALLET
LIBFABCOIN_WALLET=libfabcoin_wallet.a
endif

$(LIBSECP256K1): $(wildcard secp256k1/src/*) $(wildcard secp256k1/include/*)
	$(AM_V_at)$(MAKE) $(AM_MAKEFLAGS) -C $(@D) $(@F)

# Make is not made aware of per-object dependencies to avoid limiting building parallelization
# But to build the less dependent modules first, we manually select their order here:
EXTRA_LIBRARIES += \
  $(LIBFABCOIN_CRYPTO) \
  $(LIBFABCOIN_UTIL) \
  $(LIBFABCOIN_COMMON) \
  $(LIBFABCOIN_CONSENSUS) \
  $(LIBFABCOIN_SERVER) \
  $(LIBFABCOIN_CLI) \
  $(LIBFABCOIN_WALLET) \
  $(LIBFABCOIN_ZMQ)

lib_LTLIBRARIES = $(LIBFABCOINCONSENSUS)

bin_PROGRAMS =
noinst_PROGRAMS =
TESTS =
BENCHMARKS =

if BUILD_FABCOIND
  bin_PROGRAMS += fabcoind
endif

if BUILD_FABCOIN_UTILS
  bin_PROGRAMS += fabcoin-cli fabcoin-tx
endif

.PHONY: FORCE check-symbols check-security
# fabcoin core #
FABCOIN_CORE_H = \
  addrdb.h \
  addrman.h \
  base58.h \
  bech32.h \
  bloom.h \
  blockencodings.h \
  chain.h \
  chainparams.h \
  chainparamsbase.h \
  chainparamsseeds.h \
  checkpoints.h \
  checkqueue.h \
  clientversion.h \
  coins.h \
  compat.h \
  compat/byteswap.h \
  compat/endian.h \
  compat/sanity.h \
  compressor.h \
  consensus/consensus.h \
  consensus/tx_verify.h \
  core_io.h \
  core_memusage.h \
  cuckoocache.h \
  fs.h \
  httprpc.h \
  httpserver.h \
  indirectmap.h \
  init.h \
  key.h \
  keystore.h \
  dbwrapper.h \
  limitedmap.h \
  memusage.h \
  merkleblock.h \
  miner.h \
  net.h \
  net_processing.h \
  netaddress.h \
  netbase.h \
  netmessagemaker.h \
  noui.h \
  policy/feerate.h \
  policy/fees.h \
  policy/policy.h \
  policy/rbf.h \
  pow.h \
  pos.h \
  protocol.h \
  random.h \
  reverse_iterator.h \
  reverselock.h \
  rpc/blockchain.h \
  rpc/client.h \
  rpc/mining.h \
  rpc/protocol.h \
  rpc/safemode.h \
  rpc/server.h \
  rpc/register.h \
  rpc/util.h \
  scheduler.h \
  script/sigcache.h \
  script/sign.h \
  script/standard.h \
  script/ismine.h \
  streams.h \
  support/allocators/secure.h \
  support/allocators/zeroafterfree.h \
  support/cleanse.h \
  support/events.h \
  support/lockedpool.h \
  sync.h \
  threadsafety.h \
  threadinterrupt.h \
  timedata.h \
  torcontrol.h \
  txdb.h \
  txmempool.h \
  ui_interface.h \
  undo.h \
  util.h \
  utilmoneystr.h \
  utiltime.h \
  validation.h \
  validationinterface.h \
  versionbits.h \
  wallet/coincontrol.h \
  wallet/crypter.h \
  wallet/db.h \
  wallet/feebumper.h \
  wallet/fees.h \
  wallet/init.h \
  wallet/rpcwallet.h \
  wallet/wallet.h \
  wallet/walletdb.h \
  wallet/walletutil.h \
  warnings.h \
  zmq/zmqabstractnotifier.h \
  zmq/zmqconfig.h\
  zmq/zmqnotificationinterface.h \
  zmq/zmqpublishnotifier.h \
  fabcoin/fabcoinstate.h \
  fabcoin/fabcointransaction.h \
  fabcoin/fabcoinDGP.h \
  fabcoin/storageresults.h


if ENABLE_GPU
LIBGPUSOLVER_H = \
  libgpusolver/libgpusolver.h \
  libgpusolver/gpuconfig.h \
  libgpusolver/kernels/silentarmy.h \
  libgpusolver/libclwrapper.h \
  libgpusolver/cl.hpp \
  libgpusolver/blake.h \
  libgpusolver/param.h
endif
  
obj/build.h: FORCE
	@$(MKDIR_P) $(builddir)/obj
	@$(top_srcdir)/share/genbuild.sh "$(abs_top_builddir)/src/obj/build.h" \
	  "$(abs_top_srcdir)"
libfabcoin_util_a-clientversion.$(OBJEXT): obj/build.h

# server: shared between fabcoind and fabcoin-qt
libfabcoin_server_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES) $(MINIUPNPC_CPPFLAGS) $(EVENT_CFLAGS) $(EVENT_PTHREADS_CFLAGS) @CUDA_INCLUDES@
libfabcoin_server_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_server_a_SOURCES = \
  addrdb.cpp \
  addrman.cpp \
  bloom.cpp \
  blockencodings.cpp \
  chain.cpp \
  checkpoints.cpp \
  consensus/tx_verify.cpp \
  httprpc.cpp \
  httpserver.cpp \
  init.cpp \
  dbwrapper.cpp \
  merkleblock.cpp \
  miner.cpp \
  net.cpp \
  net_processing.cpp \
  noui.cpp \
  policy/fees.cpp \
  policy/policy.cpp \
  policy/rbf.cpp \
  pow.cpp \
  pos.cpp \
  rest.cpp \
  rpc/blockchain.cpp \
  rpc/mining.cpp \
  rpc/misc.cpp \
  rpc/net.cpp \
  rpc/rawtransaction.cpp \
  rpc/safemode.cpp \
  rpc/server.cpp \
  script/sigcache.cpp \
  script/ismine.cpp \
  timedata.cpp \
  torcontrol.cpp \
  txdb.cpp \
  txmempool.cpp \
  ui_interface.cpp \
  validation.cpp \
  validationinterface.cpp \
  versionbits.cpp \
  fabcoin/fabcoinstate.cpp \
  fabcoin/fabcointransaction.cpp \
  fabcoin/fabcoinDGP.cpp \
  consensus/consensus.cpp \
  fabcoin/storageresults.cpp \
  $(FABCOIN_CORE_H)

if ENABLE_GPU
libgpusolver_SOURCES = libgpusolver/libgpusolver.cpp libgpusolver/libclwrapper.cpp libgpusolver/blake.cpp $(LIBGPUSOLVER_H) 
libfabcoin_server_a_SOURCES += $(libgpusolver_SOURCES)
endif

if USE_CUDA
libcuda_SOURCES = cuda/cuda_equi.cu cuda/blake2b.cu cuda/blake2/blake2bx.cpp cuda/equi_miner.cu
libfabcoin_server_a_SOURCES += $(libcuda_SOURCES)
endif

if ENABLE_ZMQ
libfabcoin_zmq_a_CPPFLAGS = $(FABCOIN_INCLUDES) $(ZMQ_CFLAGS)
libfabcoin_zmq_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_zmq_a_SOURCES = \
  zmq/zmqabstractnotifier.cpp \
  zmq/zmqnotificationinterface.cpp \
  zmq/zmqpublishnotifier.cpp
endif


# wallet: shared between fabcoind and fabcoin-qt, but only linked
# when wallet enabled
libfabcoin_wallet_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
libfabcoin_wallet_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_wallet_a_SOURCES = \
  wallet/crypter.cpp \
  wallet/db.cpp \
  wallet/feebumper.cpp \
  wallet/fees.cpp \
  wallet/init.cpp \
  wallet/rpcdump.cpp \
  wallet/rpcwallet.cpp \
  wallet/wallet.cpp \
  wallet/walletdb.cpp \
  wallet/walletutil.cpp \
  pos.cpp \
  $(FABCOIN_CORE_H)

# crypto primitives library
crypto_libfabcoin_crypto_a_CPPFLAGS = $(AM_CPPFLAGS)
crypto_libfabcoin_crypto_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS) -fPIC
crypto_libfabcoin_crypto_a_CFLAGS = $(AM_CXXFLAGS) -fPIC
crypto_libfabcoin_crypto_a_SOURCES = \
  crypto/aes.cpp \
  crypto/aes.h \
  crypto/chacha20.h \
  crypto/chacha20.cpp \
  crypto/common.h \
  crypto/equihash.cpp \
  crypto/equihash.h \
  crypto/equihash.tcc \
  crypto/hmac_sha256.cpp \
  crypto/hmac_sha256.h \
  crypto/hmac_sha512.cpp \
  crypto/hmac_sha512.h \
  crypto/ripemd160.cpp \
  crypto/ripemd160.h \
  crypto/sha1.cpp \
  crypto/sha1.h \
  crypto/sha256.cpp \
  crypto/sha256.h \
  crypto/sha512.cpp \
  crypto/sha512.h \
  cpp-ethereum/utils/libscrypt/b64.c \
  cpp-ethereum/utils/libscrypt/b64.h \
  cpp-ethereum/utils/libscrypt/crypto-mcf.c \
  cpp-ethereum/utils/libscrypt/crypto_scrypt-check.c \
  cpp-ethereum/utils/libscrypt/crypto_scrypt-hash.c \
  cpp-ethereum/utils/libscrypt/crypto_scrypt-hexconvert.c \
  cpp-ethereum/utils/libscrypt/crypto_scrypt-hexconvert.h \
  cpp-ethereum/utils/libscrypt/crypto_scrypt-nosse.c \
  cpp-ethereum/utils/libscrypt/crypto-scrypt-saltgen.c \
  cpp-ethereum/utils/libscrypt/libscrypt.h \
  cpp-ethereum/utils/libscrypt/sha256.c \
  cpp-ethereum/utils/libscrypt/sha256.h \
  cpp-ethereum/utils/libscrypt/slowequals.c \
  cpp-ethereum/utils/libscrypt/slowequals.h \
  cpp-ethereum/utils/libscrypt/sysendian.h

if USE_ASM
crypto_libfabcoin_crypto_a_SOURCES += crypto/sha256_sse4.cpp
endif

# consensus: shared between all executables that validate any consensus rules.
libfabcoin_consensus_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
libfabcoin_consensus_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS) -fPIC
libfabcoin_consensus_a_SOURCES = \
  amount.h \
  arith_uint256.cpp \
  arith_uint256.h \
  consensus/merkle.cpp \
  consensus/merkle.h \
  consensus/params.h \
  consensus/validation.h \
  hash.cpp \
  hash.h \
  prevector.h \
  primitives/block.cpp \
  primitives/block.h \
  primitives/transaction.cpp \
  primitives/transaction.h \
  pubkey.cpp \
  pubkey.h \
  script/fabcoinconsensus.cpp \
  script/interpreter.cpp \
  script/interpreter.h \
  script/script.cpp \
  script/script.h \
  script/script_error.cpp \
  script/script_error.h \
  serialize.h \
  tinyformat.h \
  uint256.cpp \
  uint256.h \
  utilstrencodings.cpp \
  utilstrencodings.h \
  version.h

# common: shared between fabcoind, and fabcoin-qt and non-server tools
libfabcoin_common_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES) -DFABCOIN_BUILD
libfabcoin_common_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_common_a_CFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS) -std=c99
libfabcoin_common_a_SOURCES = \
  base58.cpp \
  bech32.cpp \
  chainparams.cpp \
  coins.cpp \
  compressor.cpp \
  core_read.cpp \
  core_write.cpp \
  key.cpp \
  keystore.cpp \
  netaddress.cpp \
  netbase.cpp \
  policy/feerate.cpp \
  protocol.cpp \
  scheduler.cpp \
  script/sign.cpp \
  script/standard.cpp \
  warnings.cpp \
  cpp-ethereum/libdevcore/Base64.cpp \
  cpp-ethereum/libdevcore/Base64.h \
  cpp-ethereum/libdevcore/Common.cpp \
  cpp-ethereum/libdevcore/Common.h \
  cpp-ethereum/libdevcore/CommonData.cpp \
  cpp-ethereum/libdevcore/CommonData.h \
  cpp-ethereum/libdevcore/CommonIO.cpp \
  cpp-ethereum/libdevcore/CommonIO.h \
  cpp-ethereum/libdevcore/CommonJS.cpp \
  cpp-ethereum/libdevcore/CommonJS.h \
  cpp-ethereum/libdevcore/FileSystem.cpp \
  cpp-ethereum/libdevcore/FileSystem.h \
  cpp-ethereum/libdevcore/FixedHash.cpp \
  cpp-ethereum/libdevcore/FixedHash.h \
  cpp-ethereum/libdevcore/Guards.cpp \
  cpp-ethereum/libdevcore/Guards.h \
  cpp-ethereum/libdevcore/Hash.cpp \
  cpp-ethereum/libdevcore/Hash.h \
  cpp-ethereum/libdevcore/Log.cpp \
  cpp-ethereum/libdevcore/Log.h \
  cpp-ethereum/libdevcore/MemoryDB.cpp \
  cpp-ethereum/libdevcore/MemoryDB.h \
  cpp-ethereum/libdevcore/OverlayDB.cpp \
  cpp-ethereum/libdevcore/OverlayDB.h \
  cpp-ethereum/libdevcore/RLP.cpp \
  cpp-ethereum/libdevcore/RLP.h \
  cpp-ethereum/libdevcore/SHA3.cpp \
  cpp-ethereum/libdevcore/SHA3.h \
  cpp-ethereum/libdevcore/TransientDirectory.cpp \
  cpp-ethereum/libdevcore/TransientDirectory.h \
  cpp-ethereum/libdevcore/TrieCommon.cpp \
  cpp-ethereum/libdevcore/TrieCommon.h \
  cpp-ethereum/libdevcore/Worker.cpp \
  cpp-ethereum/libdevcore/Worker.h \
  cpp-ethereum/libevm/ExtVMFace.cpp \
  cpp-ethereum/libevm/ExtVMFace.h \
  cpp-ethereum/libevm/VM.cpp \
  cpp-ethereum/libevm/VM.h \
  cpp-ethereum/libevm/VMOpt.cpp \
  cpp-ethereum/libevm/VMCalls.cpp \
  cpp-ethereum/libevm/VMFactory.cpp \
  cpp-ethereum/libevm/VMFactory.h \
  cpp-ethereum/libevmcore/Instruction.cpp \
  cpp-ethereum/libevmcore/Instruction.h \
  cpp-ethereum/libevmcore/Exceptions.h \
  cpp-ethereum/libevmcore/EVMSchedule.h \
  cpp-ethereum/libethereum/Account.cpp \
  cpp-ethereum/libethereum/Defaults.cpp \
  cpp-ethereum/libethereum/GasPricer.cpp \
  cpp-ethereum/libethereum/State.cpp \
  cpp-ethereum/libethcore/ABI.cpp \
  cpp-ethereum/libethcore/ChainOperationParams.cpp \
  cpp-ethereum/libethcore/Common.cpp \
  cpp-ethereum/libethcore/ICAP.cpp \
  cpp-ethereum/libethcore/Precompiled.cpp \
  cpp-ethereum/libdevcore/TrieDB.cpp \
  cpp-ethereum/libdevcrypto/Common.cpp \
  cpp-ethereum/libdevcrypto/CryptoPP.cpp \
  cpp-ethereum/libdevcrypto/AES.cpp \
  cpp-ethereum/libdevcrypto/ECDHE.cpp \
  cpp-ethereum/libethashseal/GenesisInfo.cpp \
  cpp-ethereum/libethereum/ChainParams.cpp \
  cpp-ethereum/libethcore/Transaction.cpp \
  cpp-ethereum/libethereum/Transaction.cpp \
  cpp-ethereum/libethereum/Executive.cpp \
  cpp-ethereum/libethereum/ExtVM.cpp \
  cpp-ethereum/libethereum/Block.cpp \
  cpp-ethereum/libethereum/BlockChain.cpp \
  cpp-ethereum/libethereum/BlockDetails.cpp \
  cpp-ethereum/libethereum/TransactionQueue.cpp \
  cpp-ethereum/libethereum/BlockQueue.cpp \
  cpp-ethereum/libethcore/BlockHeader.cpp \
  cpp-ethereum/libdevcore/RLP.cpp \
  cpp-ethereum/libethereum/TransactionReceipt.cpp \
  cpp-ethereum/libethcore/SealEngine.cpp \
  cpp-ethereum/libdevcore/TrieHash.cpp \
  cpp-ethereum/libethereum/GenesisInfo.cpp \
  cpp-ethereum/libethashseal/Ethash.cpp \
  cpp-ethereum/libethashseal/EthashCPUMiner.cpp \
  cpp-ethereum/libethashseal/EthashAux.cpp \
  cpp-ethereum/libethashseal/EthashProofOfWork.cpp \
  cpp-ethereum/libethereum/Account.h \
  cpp-ethereum/libethereum/Defaults.h \
  cpp-ethereum/libethereum/GasPricer.h \
  cpp-ethereum/libethereum/State.h \
  cpp-ethereum/libethcore/ABI.h \
  cpp-ethereum/libethcore/ChainOperationParams.h \
  cpp-ethereum/libethcore/Common.h \
  cpp-ethereum/libethcore/ICAP.h \
  cpp-ethereum/libethcore/Precompiled.h \
  cpp-ethereum/libdevcore/TrieDB.h \
  cpp-ethereum/libdevcrypto/Common.h \
  cpp-ethereum/libdevcrypto/CryptoPP.h \
  cpp-ethereum/libdevcrypto/AES.h \
  cpp-ethereum/libdevcrypto/ECDHE.h \
  cpp-ethereum/libethashseal/GenesisInfo.h \
  cpp-ethereum/libethereum/ChainParams.h \
  cpp-ethereum/libethcore/Transaction.h \
  cpp-ethereum/libethcore/Exceptions.h \
  cpp-ethereum/libethereum/Transaction.h \
  cpp-ethereum/libethereum/Executive.h \
  cpp-ethereum/libethereum/ExtVM.h \
  cpp-ethereum/libethereum/Block.h \
  cpp-ethereum/libethereum/BlockChain.h \
  cpp-ethereum/libethereum/BlockDetails.h \
  cpp-ethereum/libethereum/TransactionQueue.h \
  cpp-ethereum/libethereum/BlockQueue.h \
  cpp-ethereum/libethcore/BlockHeader.h \
  cpp-ethereum/libdevcore/RLP.h \
  cpp-ethereum/libethereum/TransactionReceipt.h \
  cpp-ethereum/libethcore/SealEngine.h \
  cpp-ethereum/libdevcore/TrieHash.h \
  cpp-ethereum/libethereum/GenesisInfo.h \
  cpp-ethereum/libethashseal/Ethash.h \
  cpp-ethereum/libethashseal/EthashCPUMiner.h \
  cpp-ethereum/libethashseal/EthashAux.h \
  cpp-ethereum/libethashseal/EthashProofOfWork.h \
  cpp-ethereum/libethash/internal.c \
  cpp-ethereum/libethash/io.c \
  cpp-ethereum/libethash/sha3.c \
  cpp-ethereum/libethash/internal.h \
  cpp-ethereum/libethash/io.h \
  cpp-ethereum/libethash/sha3.h \
  cpp-ethereum/libdevcore/vector_ref.h \
  cpp-ethereum/libdevcore/Exceptions.h \
  cpp-ethereum/libdevcore/db.h \
  cpp-ethereum/libdevcore/concurrent_queue.h \
  cpp-ethereum/libdevcore/Terminal.h \
  cpp-ethereum/libethereum/CodeSizeCache.h \
  cpp-ethereum/libethereum/VerifiedBlock.h \
  cpp-ethereum/libdevcore/Assertions.h \
  cpp-ethereum/libdevcore/debugbreak.h \
  cpp-ethereum/libethereum/GenericMiner.h \
  cpp-ethereum/libevm/VMFace.h \
  cpp-ethereum/libethereum/GenericFarm.h \
  cpp-ethereum/libethereum/Interface.h \
  cpp-ethereum/libethcore/CommonJS.h \
  cpp-ethereum/libdevcore/picosha2.h \
  cpp-ethereum/libevm/VMConfig.h \
  cpp-ethereum/libethereum/LogFilter.h \
  cpp-ethereum/libdevcrypto/Exceptions.h \
  cpp-ethereum/libethashseal/genesis/mainNetwork.cpp \
  cpp-ethereum/libethashseal/genesis/eip150Test.cpp \
  cpp-ethereum/libethashseal/genesis/eip158Test.cpp \
  cpp-ethereum/libethashseal/genesis/frontierTest.cpp \
  cpp-ethereum/libethashseal/genesis/homesteadTest.cpp \
  cpp-ethereum/libethashseal/genesis/mainNetworkTest.cpp \
  cpp-ethereum/libethashseal/genesis/metropolisTest.cpp \
  cpp-ethereum/libethashseal/genesis/fabcoinMainNetwork.cpp \
  cpp-ethereum/libethashseal/genesis/fabcoinTestNetwork.cpp \
  cpp-ethereum/libethashseal/genesis/ropsten.cpp \
  cpp-ethereum/libethashseal/genesis/transitionnetTest.cpp \
  cpp-ethereum/libethash/ethash.h \
  cpp-ethereum/libethash/compiler.h \
  cpp-ethereum/libethash/data_sizes.h \
  cpp-ethereum/libethash/fnv.h \
  cpp-ethereum/libethash/mmap.h \
  cpp-ethereum/libethash/endian.h \
  cpp-ethereum/libethash/io.h \
  cpp-ethereum/libethash/ethash.h \
  cpp-ethereum/libethash/internal.h \
  cpp-ethereum/libethash/mmap_win32.c \
  cpp-ethereum/utils/json_spirit/JsonSpiritHeaders.h \
  cpp-ethereum/utils/json_spirit/json_spirit.h \
  cpp-ethereum/utils/json_spirit/json_spirit_error_position.h \
  cpp-ethereum/utils/json_spirit/json_spirit_reader.h \
  cpp-ethereum/utils/json_spirit/json_spirit_reader_template.h \
  cpp-ethereum/utils/json_spirit/json_spirit_stream_reader.h \
  cpp-ethereum/utils/json_spirit/json_spirit_utils.h \
  cpp-ethereum/utils/json_spirit/json_spirit_value.h \
  cpp-ethereum/utils/json_spirit/json_spirit_writer.h \
  cpp-ethereum/utils/json_spirit/json_spirit_writer_template.h \
  $(FABCOIN_CORE_H)

#only added json_spirit so that `make dist` works properly

if TARGET_WINDOWS
  libfabcoin_common_a_SOURCES += \
    cpp-ethereum/libethash/io_win32.c \
    cpp-ethereum/libethash/util_win32.c
else
  libfabcoin_common_a_SOURCES += cpp-ethereum/libethash/io_posix.c
endif

# util: shared between all executables.
# This library *must* be included to make sure that the glibc
# backward-compatibility objects and their sanity checks are linked.
libfabcoin_util_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
libfabcoin_util_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_util_a_SOURCES = \
  support/lockedpool.cpp \
  chainparamsbase.cpp \
  clientversion.cpp \
  compat/glibc_sanity.cpp \
  compat/glibcxx_sanity.cpp \
  compat/strnlen.cpp \
  fs.cpp \
  random.cpp \
  rpc/protocol.cpp \
  rpc/util.cpp \
  support/cleanse.cpp \
  sync.cpp \
  threadinterrupt.cpp \
  util.cpp \
  utilmoneystr.cpp \
  utilstrencodings.cpp \
  utiltime.cpp \
  $(FABCOIN_CORE_H)

if GLIBC_BACK_COMPAT
libfabcoin_util_a_SOURCES += compat/glibc_compat.cpp
endif

# cli: shared between fabcoin-cli and fabcoin-qt
libfabcoin_cli_a_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
libfabcoin_cli_a_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
libfabcoin_cli_a_SOURCES = \
  rpc/client.cpp \
  $(FABCOIN_CORE_H)

nodist_libfabcoin_util_a_SOURCES = $(srcdir)/obj/build.h
#

# fabcoind binary #
fabcoind_SOURCES = fabcoind.cpp
fabcoind_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
fabcoind_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
fabcoind_LDFLAGS = $(RELDFLAGS) $(AM_LDFLAGS) $(LIBTOOL_APP_LDFLAGS)

if TARGET_WINDOWS
fabcoind_SOURCES += fabcoind-res.rc
endif

fabcoind_LDADD = \
  $(LIBFABCOIN_SERVER) \
  $(LIBFABCOIN_COMMON) \
  $(LIBUNIVALUE) \
  $(LIBFABCOIN_UTIL) \
  $(LIBFABCOIN_WALLET) \
  $(LIBFABCOIN_ZMQ) \
  $(LIBFABCOIN_CONSENSUS) \
  $(LIBFABCOIN_CRYPTO) \
  $(LIBLEVELDB) \
  $(LIBLEVELDB_SSE42) \
  $(LIBMEMENV) \
  $(LIBCRYPTOPP) \
  $(LIBSECP256K1)

fabcoind_LDADD += $(BOOST_LIBS) $(BDB_LIBS) $(SSL_LIBS) $(CRYPTO_LIBS) $(MINIUPNPC_LIBS) $(EVENT_PTHREADS_LIBS) $(EVENT_LIBS) $(ZMQ_LIBS) $(LIBEQUIHASH_LIBS)

# fabcoin-cli binary #
fabcoin_cli_SOURCES = fabcoin-cli.cpp
fabcoin_cli_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES) $(EVENT_CFLAGS)
fabcoin_cli_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
fabcoin_cli_LDFLAGS = $(RELDFLAGS) $(AM_LDFLAGS) $(LIBTOOL_APP_LDFLAGS)

if TARGET_WINDOWS
fabcoin_cli_SOURCES += fabcoin-cli-res.rc
endif

fabcoin_cli_LDADD = \
  $(LIBFABCOIN_CLI) \
  $(LIBUNIVALUE) \
  $(LIBFABCOIN_UTIL) \
  $(LIBFABCOIN_CRYPTO) \
  $(LIBLEVELDB) \
  $(LIBLEVELDB_SSE42) \
  $(LIBMEMENV) \
  $(LIBCRYPTOPP) \
  $(LIBSECP256K1)

fabcoin_cli_LDADD += $(BOOST_LIBS) $(SSL_LIBS) $(CRYPTO_LIBS) $(EVENT_LIBS) $(LIBEQUIHASH_LIBS)
#

# fabcoin-tx binary #
fabcoin_tx_SOURCES = fabcoin-tx.cpp consensus/consensus.cpp
fabcoin_tx_CPPFLAGS = $(AM_CPPFLAGS) $(FABCOIN_INCLUDES)
fabcoin_tx_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)
fabcoin_tx_LDFLAGS = $(RELDFLAGS) $(AM_LDFLAGS) $(LIBTOOL_APP_LDFLAGS)

if TARGET_WINDOWS
fabcoin_tx_SOURCES += fabcoin-tx-res.rc
endif

fabcoin_tx_LDADD = \
  $(LIBUNIVALUE) \
  $(LIBFABCOIN_COMMON) \
  $(LIBFABCOIN_UTIL) \
  $(LIBFABCOIN_CONSENSUS) \
  $(LIBFABCOIN_CRYPTO) \
  $(LIBLEVELDB) \
  $(LIBLEVELDB_SSE42) \
  $(LIBMEMENV) \
  $(LIBCRYPTOPP) \
  $(LIBSECP256K1) \
  $(LIBEQUIHASH_LIBS)

fabcoin_tx_LDADD += $(BOOST_LIBS) $(CRYPTO_LIBS)
#

# fabcoinconsensus library #
if BUILD_FABCOIN_LIBS
include_HEADERS = script/fabcoinconsensus.h
libfabcoinconsensus_la_SOURCES = $(crypto_libfabcoin_crypto_a_SOURCES) $(libfabcoin_consensus_a_SOURCES)

if GLIBC_BACK_COMPAT
  libfabcoinconsensus_la_SOURCES += compat/glibc_compat.cpp
endif

libfabcoinconsensus_la_LDFLAGS = $(AM_LDFLAGS) -no-undefined $(RELDFLAGS)
libfabcoinconsensus_la_LIBADD = $(LIBSECP256K1) $(LIBEQUIHASH_LIBS)
libfabcoinconsensus_la_CPPFLAGS = $(AM_CPPFLAGS) -I$(builddir)/obj -I$(srcdir)/secp256k1/include $(FABCOIN_INCLUDES) -DBUILD_FABCOIN_INTERNAL
libfabcoinconsensus_la_CXXFLAGS = $(AM_CXXFLAGS) $(PIE_FLAGS)

endif
#

CTAES_DIST =  crypto/ctaes/bench.c
CTAES_DIST += crypto/ctaes/ctaes.c
CTAES_DIST += crypto/ctaes/ctaes.h
CTAES_DIST += crypto/ctaes/README.md
CTAES_DIST += crypto/ctaes/test.c

CLEANFILES = $(EXTRA_LIBRARIES)

CLEANFILES += *.gcda *.gcno
CLEANFILES += compat/*.gcda compat/*.gcno
CLEANFILES += consensus/*.gcda consensus/*.gcno
CLEANFILES += crypto/*.gcda crypto/*.gcno
CLEANFILES += policy/*.gcda policy/*.gcno
CLEANFILES += primitives/*.gcda primitives/*.gcno
CLEANFILES += script/*.gcda script/*.gcno
CLEANFILES += support/*.gcda support/*.gcno
CLEANFILES += univalue/*.gcda univalue/*.gcno
CLEANFILES += wallet/*.gcda wallet/*.gcno
CLEANFILES += wallet/test/*.gcda wallet/test/*.gcno
CLEANFILES += zmq/*.gcda zmq/*.gcno
CLEANFILES += obj/build.h

EXTRA_DIST = $(CTAES_DIST)


config/fabcoin-config.h: config/stamp-h1
	@$(MAKE) -C $(top_builddir) $(subdir)/$(@)
config/stamp-h1: $(top_srcdir)/$(subdir)/config/fabcoin-config.h.in $(top_builddir)/config.status
	$(AM_V_at)$(MAKE) -C $(top_builddir) $(subdir)/$(@)
$(top_srcdir)/$(subdir)/config/fabcoin-config.h.in:  $(am__configure_deps)
	$(AM_V_at)$(MAKE) -C $(top_srcdir) $(subdir)/config/fabcoin-config.h.in

clean-local:
	-$(MAKE) -C secp256k1 clean
	-$(MAKE) -C univalue clean
	-rm -f leveldb/*/*.gcda leveldb/*/*.gcno leveldb/helpers/memenv/*.gcda leveldb/helpers/memenv/*.gcno
	-rm -f cryptopp/*.o
	-rm -f config.h
	-rm -rf test/__pycache__

if USE_CUDA
nvcc_ARCH :=
nvcc_ARCH += -gencode=arch=compute_52,code=\"sm_52,compute_52\"
nvcc_ARCH += -gencode=arch=compute_50,code=\"sm_50,compute_50\"

nvcc_FLAGS = $(nvcc_ARCH) @CUDA_INCLUDES@ -I. @CUDA_CFLAGS@
nvcc_FLAGS += $(JANSSON_INCLUDES) --ptxas-options="-v"
endif

if USE_CUDA
# we're now targeting all major compute architectures within one binary.
.cu.o:
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=128 -o $@ -c $<

cuda/cuda_equi.o: cuda/cuda_equi.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=64 -o $@ -c $<
cuda/equi_miner.o: cuda/equi_miner.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=64 -o $@ -c $<
cuda/blake2b.o: cuda/blake2b.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=64 -o $@ -c $<
endif

.rc.o:
	@test -f $(WINDRES)
	## FIXME: How to get the appropriate modulename_CPPFLAGS in here?
	$(AM_V_GEN) $(WINDRES) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(CPPFLAGS) -DWINDRES_PREPROC -i $< -o $@

check-symbols: $(bin_PROGRAMS)
if GLIBC_BACK_COMPAT
	@echo "Checking glibc back compat..."
	$(AM_V_at) READELF=$(READELF) CPPFILT=$(CPPFILT) $(top_srcdir)/contrib/devtools/symbol-check.py < $(bin_PROGRAMS)
endif

check-security: $(bin_PROGRAMS)
if HARDEN
	@echo "Checking binary security..."
	$(AM_V_at) READELF=$(READELF) OBJDUMP=$(OBJDUMP) $(top_srcdir)/contrib/devtools/security-check.py < $(bin_PROGRAMS)
endif

%.pb.cc %.pb.h: %.proto
	@test -f $(PROTOC)
	$(AM_V_GEN) $(PROTOC) --cpp_out=$(@D) --proto_path=$(<D) $<

if EMBEDDED_LEVELDB
include Makefile.leveldb.include
endif

include Makefile.cryptopp.include

if ENABLE_TESTS
include Makefile.test.include
endif

if ENABLE_BENCH
include Makefile.bench.include
endif

if ENABLE_QT
include Makefile.qt.include
endif

if ENABLE_QT_TESTS
include Makefile.qttest.include
endif
