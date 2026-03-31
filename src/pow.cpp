// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2022 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <pow.h>

#include <arith_uint256.h>
#include <chain.h>
#include <primitives/block.h>
#include <uint256.h>
#include <util/check.h>

// Zetacoin difficulty adjustment constants
static const int64_t nTargetTimespan = 2 * 60; // 2 minutes
static const int64_t nTargetSpacing = 30; // 30 seconds
static const int64_t nInterval = nTargetTimespan / nTargetSpacing; // 4 blocks

static const int64_t nAveragingInterval = nInterval * 20; // 80 blocks
static const int64_t nAveragingTargetTimespan = nAveragingInterval * nTargetSpacing; // 40 minutes

static const int64_t nMaxAdjustDown = 20; // 20% adjustment down
static const int64_t nMaxAdjustUp = 1; // 1% adjustment up

static const int64_t nMinActualTimespan = nAveragingTargetTimespan * (100 - nMaxAdjustUp) / 100;
static const int64_t nMaxActualTimespan = nAveragingTargetTimespan * (100 + nMaxAdjustDown) / 100;

unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params& params)
{
    unsigned int nProofOfWorkLimit = UintToArith256(params.powLimit).GetCompact();

    // Genesis block
    if (pindexLast == nullptr)
        return nProofOfWorkLimit;

    if (pindexLast->nHeight+1 < nAveragingInterval)
        return nProofOfWorkLimit;

    // Only change once per difficulty adjustment interval
    if ((pindexLast->nHeight+1) % nInterval != 0)
    {
        if (params.fPowAllowMinDifficultyBlocks)
        {
            // Special difficulty rule for testnet:
            // If the new block's timestamp is more than 2 * nTargetSpacing
            // then allow mining of a min-difficulty block.
            if (pblock->GetBlockTime() > pindexLast->GetBlockTime() + nTargetSpacing*2)
                return nProofOfWorkLimit;
            else
            {
                // Return the last non-special-min-difficulty-rules-block
                const CBlockIndex* pindex = pindexLast;
                while (pindex->pprev && pindex->nHeight % nInterval != 0 && pindex->nBits == nProofOfWorkLimit)
                    pindex = pindex->pprev;
                return pindex->nBits;
            }
        }
        return pindexLast->nBits;
    }

    // Go back by what we want to be nAveragingInterval blocks
    const CBlockIndex* pindexFirst = pindexLast;
    for (int i = 0; pindexFirst && i < nAveragingInterval-1; i++)
        pindexFirst = pindexFirst->pprev;
    assert(pindexFirst);

    return CalculateNextWorkRequired(pindexLast, pindexFirst->GetBlockTime(), params);
}

unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast, int64_t nFirstBlockTime, const Consensus::Params& params)
{
    if (params.fPowNoRetargeting)
        return pindexLast->nBits;

    // Limit adjustment step
    int64_t nActualTimespan = pindexLast->GetBlockTime() - nFirstBlockTime;
    if (nActualTimespan < nMinActualTimespan)
        nActualTimespan = nMinActualTimespan;
    if (nActualTimespan > nMaxActualTimespan)
        nActualTimespan = nMaxActualTimespan;

    // Retarget
    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
    arith_uint256 bnNew;
    bnNew.SetCompact(pindexLast->nBits);
    bnNew *= nActualTimespan;
    bnNew /= nAveragingTargetTimespan;

    if (bnNew > bnPowLimit)
        bnNew = bnPowLimit;

    return bnNew.GetCompact();
}

// Check that on difficulty adjustments, the new difficulty does not increase
// or decrease beyond the permitted limits.
bool PermittedDifficultyTransition(const Consensus::Params& params, int64_t height, uint32_t old_nbits, uint32_t new_nbits)
{
    if (params.fPowAllowMinDifficultyBlocks) return true;

    if (height % nInterval == 0) {
        const arith_uint256 pow_limit = UintToArith256(params.powLimit);
        arith_uint256 observed_new_target;
        observed_new_target.SetCompact(new_nbits);

        // Calculate the largest difficulty value possible (max adjustment down = easiest target):
        arith_uint256 largest_difficulty_target;
        largest_difficulty_target.SetCompact(old_nbits);
        largest_difficulty_target *= nMaxActualTimespan;
        largest_difficulty_target /= nAveragingTargetTimespan;

        if (largest_difficulty_target > pow_limit) {
            largest_difficulty_target = pow_limit;
        }

        // Compare against full-precision bound. Do NOT round-trip through
        // SetCompact(GetCompact()) as the precision loss from compact encoding
        // can reject valid transitions at the boundary. Zetacoin's tight 1% max
        // upward adjustment with 80-block averaging produces transitions that
        // exceed the compact-rounded bound by ~0.0004%.
        if (largest_difficulty_target < observed_new_target) return false;

        // Calculate the smallest difficulty value possible (max adjustment up = hardest target):
        arith_uint256 smallest_difficulty_target;
        smallest_difficulty_target.SetCompact(old_nbits);
        smallest_difficulty_target *= nMinActualTimespan;
        smallest_difficulty_target /= nAveragingTargetTimespan;

        if (smallest_difficulty_target > pow_limit) {
            smallest_difficulty_target = pow_limit;
        }

        if (smallest_difficulty_target > observed_new_target) return false;
    } else if (old_nbits != new_nbits) {
        return false;
    }
    return true;
}

// Bypasses the actual proof of work check during fuzz testing with a simplified validation checking whether
// the most significant bit of the last byte of the hash is set.
bool CheckProofOfWork(uint256 hash, unsigned int nBits, const Consensus::Params& params)
{
    if (EnableFuzzDeterminism()) return (hash.data()[31] & 0x80) == 0;
    return CheckProofOfWorkImpl(hash, nBits, params);
}

std::optional<arith_uint256> DeriveTarget(unsigned int nBits, const uint256 pow_limit)
{
    bool fNegative;
    bool fOverflow;
    arith_uint256 bnTarget;

    bnTarget.SetCompact(nBits, &fNegative, &fOverflow);

    // Check range
    if (fNegative || bnTarget == 0 || fOverflow || bnTarget > UintToArith256(pow_limit))
        return {};

    return bnTarget;
}

bool CheckProofOfWorkImpl(uint256 hash, unsigned int nBits, const Consensus::Params& params)
{
    auto bnTarget{DeriveTarget(nBits, params.powLimit)};
    if (!bnTarget) return false;

    // Check proof of work matches claimed amount
    if (UintToArith256(hash) > bnTarget)
        return false;

    return true;
}
