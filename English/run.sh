#!/bin/bash
. ./path.sh || exit 1
. ./cmd.sh || exit 1
set -euxo pipefail
nj=4       # number of parallel jobs - 1 is perfect for such a small dataset
lm_order=1 # language model order (n-gram quantity) - 1 is enough for digits grammar
# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }
# Removing previously created data (from last run.sh execution)
#rm -rf exp mfcc data/train/cmvn.scp data/train/feats.scp data/train/split1 data/test/cmvn.scp data/test/feats.scp data/test/split1 data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt #data/train/spk2utt data/test/spk2utt
#rm -rf data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt 
echo
echo "===== PREPARING ACOUSTIC DATA ====="
echo
# Needs to be prepared by hand (or using self written scripts):
#
# spk2gender  [<speaker-id> <gender>]
# wav.scp     [<uterranceID> <full_path_to_audio_file>]
# text        [<uterranceID> <text_transcription>]
# utt2spk     [<uterranceID> <speakerID>]
# corpus.txt  [<text_transcription>]
# Making spk2utt files
#utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
#utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt
echo
echo "===== FEATURES EXTRACTION ====="
echo
# Making feats.scp files
mfccdir=mfcc
# Uncomment and modify arguments in scripts below if you have any problems with data sorting
#utils/validate_data_dir.sh data/train     # script for checking prepared data - here: for data/train directory
#utils/fix_data_dir.sh data/train          # tool for data proper sorting if needed - here: for data/train directory
#steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
#steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir
# Making cmvn.scp files
#steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
#steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir
echo
echo "===== PREPARING LANGUAGE DATA ====="
echo
# Needs to be prepared by hand (or using self written scripts):
#
# lexicon.txt           [<word> <phone 1> <phone 2> ...]
# nonsilence_phones.txt [<phone>]
# silence_phones.txt    [<phone>]
# optional_silence.txt  [<phone>]
# Preparing language data
#utils/prepare_lang.sh data/local/dict "<OOV>" data/local/lang data/lang
echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo
#loc=`which ngram-count`;
#if [ -z $loc ]; then
#        if uname -a | grep 64 >/dev/null; then
#                sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
#        else
#                        sdir=$KALDI_ROOT/tools/srilm/bin/i686
#        fi
#        if [ -f $sdir/ngram-count ]; then
#                        echo "Using SRILM language modelling tool from $sdir"
#                       export PATH=$PATH:$sdir
#        else
#                        echo "SRILM toolkit is probably not installed.
#                                Instructions: tools/install_srilm.sh"
#                       exit 1
#        fi
#fi
local=data/local
#mkdir $local/tmp
#ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa
echo
echo "===== MAKING G.fst ====="
echo
lang=data/lang
#arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt $local/tmp/lm.arpa $lang/G.fst 
echo
echo "===== MONO TRAINING ====="
echo
#steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/traintest data/lang exp/mono  || exit 1
echo
echo "===== MONO DECODING ====="
echo
#utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode
echo
echo "===== MONO ALIGNMENT ====="
echo
#steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1
echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo
#steps/train_deltas.sh --cmd "$train_cmd" 4000 20000 data/train data/lang exp/mono_ali exp/tri1 || exit 1
echo
echo "===== TRI1 (first triphone pass) DECODING ====="
echo
#utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode
echo
echo "===== TRI1 (first triphone pass) ALIGNMENT ====="
echo
#steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri1 exp/tri1_ali || exit 1;
echo
echo "===== TRI2A TRAINING ====="
echo
#steps/train_deltas.sh --cmd "$train_cmd" 6000 40000 data/train data/lang exp/tri1_ali exp/tri2a || exit 1;
echo
echo "===== TRI2A DECODING ====="
echo
#utils/mkgraph.sh data/lang exp/tri2a exp/tri2a/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri2a/graph data/test exp/tri2a/decode
echo
echo "===== TRI2A ALIGNMENT ====="
echo
#steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri2a exp/tri2a_ali || exit 1; #4000 30000
echo
echo "===== TRI3A TRAINING ====="
echo
#steps/train_lda_mllt.sh --cmd "$train_cmd" 8000 80000 data/train data/lang exp/tri2a_ali exp/tri3c || exit 1;
echo
echo "===== TRI3A DECODING ====="
echo
#utils/mkgraph.sh data/lang exp/tri3c exp/tri3c/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri3c/graph data/test exp/tri3c/decode
echo
echo "===== TRI3A ALIGNMENT ====="
echo
steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri3c exp/tri3c_ali || exit 1;
echo
echo "===== TRI4A TRAINING ====="
echo
steps/train_sat.sh  --cmd "$train_cmd" 12000 120000 data/train data/lang exp/tri3c_ali exp/tri4b || exit 1;
echo
echo "===== TRI4A DECODING ====="
echo
utils/mkgraph.sh data/lang exp/tri4b exp/tri4b/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri4b/graph data/test exp/tri4b/decode
echo
echo "===== TRI4A ALIGNMENT ====="
echo
#steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri3a exp/tri3a_ali || exit 1;
echo
echo "===== run.sh script is finished ====="
echo
